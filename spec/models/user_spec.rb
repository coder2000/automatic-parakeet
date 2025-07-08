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
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_locale                (locale)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  # Shoulda Matchers
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  # Custom logic
  it "defaults staff to false" do
    expect(user.staff).to eq(false)
  end

  it "defaults notification_count to 0" do
    expect(user.notification_count).to eq(0)
  end

  it "defaults score to 0" do
    expect(user.score).to eq(0)
  end

  it "can have a given_name, surname, and phone_number" do
    user.given_name = "Jane"
    user.surname = "Doe"
    user.phone_number = "+1234567890"
    expect(user).to be_valid
  end
end
