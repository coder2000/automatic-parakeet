# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  given_name             :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locale                 :string
#  notification_count     :integer          default(0), not null
#  phone_number           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  score                  :integer          default(0), not null
#  sign_in_count          :integer          default(0), not null
#  staff                  :boolean          default(FALSE), not null
#  surname                :string
#  unconfirmed_email      :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_locale                (locale)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    email { Faker::Internet.unique.email }
    password { "password123" }
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
