require 'active_support/all'
require 'logger'
require 'sequel'

### data ######################################################################

PERSONAS_DUMP = '../datalayer/db/personas.pgbin'

### sequel ####################################################################

# general rules for getting connection env params
#
# 1. DB_ 
# 2. PG_
# 3. some sensible default constant


def database_name
  ENV['DB_NAME_TEST'].presence || 
    ENV['DATABASE'].presence ||
    ENV['DB_NAME'].presence || 
    ENV['PGDATABASE'].presence ||
    'madek'
end

def database_user
  ENV['DB_USER'].presence || 
    ENV['PGUSER'].presence || 
    'postgres'
end

def database_password
  ENV['DB_PASSWORD'].presence ||
    ENV['PGPASSWORD'].presence
end

def database_host 
  ENV['DB_HOST'].presence ||
    ENV['PGHOST'].presence || 
    'localhost'
end

def database_port 
  Integer(
    ENV['DB_PORT'].presence || 
    ENV['PGPORT'].presence || 
    5415
  )
end

def database
  @database ||= Sequel.postgres(
    database: database_name, 
    user: database_user,
    password: database_password,
    host: database_host ,
    port: database_port)
end

database.extension :pg_json
database.wrap_json_primitives = true


### helpers ###################################################################



def db_clean
  tables = database[ <<-SQL.strip_heredoc
    SELECT table_name
      FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
    AND table_schema = 'public'
    ORDER BY table_type, table_name;
                     SQL
  ].map{|r| r[:table_name]}.reject { |tn| tn == 'schema_migrations' } \
    .join(', ').tap do |tables|
      database.run" TRUNCATE TABLE #{tables} CASCADE; "
    end
end


def db_restore_data
  shell_filename = Shellwords.escape(PERSONAS_DUMP)
  list_cmd = "pg_restore -l #{shell_filename}"
  pg_list = `#{list_cmd}`
  raise "Command #{list_cmd} failed " if $?.exitstatus != 0
  restore_list = pg_list.split(/\n/) \
    .reject{|l| l =~ /TABLE DATA .* schema_migrations/}
    .reject{|l| l =~ /TABLE DATA .* ar_internal_metadata/}
    .join("\n")
  begin
    restore_list_file = Tempfile.new('pg_restore_list')
    restore_list_file.write restore_list

    command = 'pg_restore --data-only --exit-on-error ' \
      ' --disable-triggers --single-transaction --no-privileges --no-owner ' \
      " -d #{database_name} " \
      " --use-list=#{restore_list_file.path} " \
      " #{shell_filename}"

    Kernel.system(command, exception: true)
    $stdout.puts "Data from '#{shell_filename}' has been restored to '#{database_name}'"
  ensure
    restore_list_file.close
    restore_list_file.unlink
  end
end


def db_with_disabled_triggers
  database.run 'SET session_replication_role = REPLICA;'
  result = yield
  database.run 'SET session_replication_role = DEFAULT;'
  result
end
