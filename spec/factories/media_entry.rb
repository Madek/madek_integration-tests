class MediaEntry < Sequel::Model
  one_to_one :media_file
end
