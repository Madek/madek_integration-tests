class User < Sequel::Model
end

FactoryBot.define do
  factory :user do
    person_id { create(:person).id }
    email do
      Faker::Internet.email.gsub('@',
                                 '_' + SecureRandom.uuid.first(8) + '@')
    end
    login { Faker::Internet.user_name + (SecureRandom.uuid.first 8) }
    password_sign_in_enabled { true }

    after(:build) do |user|
      person = Person.find(id: user.person_id)
      user.first_name ||= person.first_name
      user.last_name ||= person.last_name
    end
  end
end
