FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { password }
    staff { false }
    notification_count { 0 }
    score { 0 }
    given_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    confirmed_at { Time.current } # For Devise confirmable
  end
end
