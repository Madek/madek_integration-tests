class Role < Sequel::Model
  many_to_many :roles_lists, join_table: :roles_lists_roles
end

FactoryBot.define do
  factory :role do
    labels do
      { AppSetting.default_locale => Faker::Lorem.characters(number: 10) }
    end
    association :creator, factory: :user
  end
end
