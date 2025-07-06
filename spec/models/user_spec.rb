require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it 'is valid with valid attributes' do
    expect(user).to be_valid
  end

  it 'is invalid without an email' do
    user.email = nil
    expect(user).not_to be_valid
  end

  it 'is invalid without a password' do
    user.password = nil
    expect(user).not_to be_valid
  end

  it 'defaults staff to false' do
    expect(user.staff).to eq(false)
  end

  it 'defaults notification_count to 0' do
    expect(user.notification_count).to eq(0)
  end

  it 'defaults score to 0' do
    expect(user.score).to eq(0)
  end

  it 'can have a given_name, surname, and phone_number' do
    user.given_name = 'Jane'
    user.surname = 'Doe'
    user.phone_number = '+1234567890'
    expect(user).to be_valid
  end

  it 'requires unique email' do
    create(:user, email: user.email)
    expect(user).not_to be_valid
  end
end
