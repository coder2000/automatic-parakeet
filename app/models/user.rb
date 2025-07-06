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
class User < ApplicationRecord
  # Store user's preferred locale
  # Add a migration to add a `locale` column to users table if not present
  # Example: rails g migration AddLocaleToUsers locale:string

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  # Returns the user's preferred locale, or nil if not set
  def preferred_locale
    locale.presence
  end
end
