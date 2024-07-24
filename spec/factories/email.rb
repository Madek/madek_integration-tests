class Email < Sequel::Model
end

FactoryBot.define do
  factory :email do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    from_address { Faker::Internet.email }

    after(:build) do |email|
      user = User.find(id: email.user_id)
      email.to_address = user.email
    end
  end
end
