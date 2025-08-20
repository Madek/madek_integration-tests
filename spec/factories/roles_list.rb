class RolesList < Sequel::Model
  many_to_many :roles, join_table: :roles_lists_roles
end

FactoryBot.define do
  factory :roles_list do
    labels do
      { AppSetting.default_locale => Faker::Lorem.characters(number: 10) }
    end
  end
end
