class Preview < Sequel::Model
  many_to_one :media_file
end

