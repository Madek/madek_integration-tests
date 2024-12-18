class Person < Sequel::Model(:people)
  one_to_one :user
end

FactoryBot.define do
  factory :person do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    pseudonym { Faker::Name.name }
    description { Faker::Lorem.sentence }
  end
end
