class MediaFile < Sequel::Model
  one_to_many :previews
  one_to_one :media_entry
end
