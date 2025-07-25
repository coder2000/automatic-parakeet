# == Schema Information
#
# Table name: ahoy_visits
#
#  id               :bigint           not null, primary key
#  app_version      :string
#  browser          :string
#  city             :string
#  country          :string
#  device_type      :string
#  ip               :string
#  landing_page     :text
#  latitude         :float
#  longitude        :float
#  os               :string
#  os_version       :string
#  platform         :string
#  referrer         :text
#  referring_domain :string
#  region           :string
#  started_at       :datetime
#  user_agent       :text
#  utm_campaign     :string
#  utm_content      :string
#  utm_medium       :string
#  utm_source       :string
#  utm_term         :string
#  visit_token      :string
#  visitor_token    :string
#  user_id          :bigint
#
# Indexes
#
#  index_ahoy_visits_on_user_id                       (user_id)
#  index_ahoy_visits_on_visit_token                   (visit_token) UNIQUE
#  index_ahoy_visits_on_visitor_token_and_started_at  (visitor_token,started_at)
#
class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user, optional: true

  # Define searchable attributes for Ransack (excluding sensitive location data)
  def self.ransackable_attributes(auth_object = nil)
    %w[browser device_type os os_version platform referrer referring_domain started_at utm_campaign utm_content utm_medium utm_source utm_term app_version]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[events user]
  end
end
