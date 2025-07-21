# == Schema Information
#
# Table name: downloads
#
#  id               :bigint           not null, primary key
#  count            :integer          default(0)
#  ip_address       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  download_link_id :bigint
#  user_id          :bigint
#
# Indexes
#
#  index_downloads_on_download_link_id  (download_link_id)
#  index_downloads_on_user_id           (user_id)
#
FactoryBot.define do
  factory :download do
    association :download_link
    association :user
    count { 0 }

    trait :with_user do
      association :user
    end

    trait :anonymous do
      user { nil }
      sequence(:ip_address) { |n| "192.168.1.#{n % 254 + 1}" }
    end

    trait :bulk do
      count { rand(1..10) }
    end

    trait :recent do
      created_at { rand(1.hour.ago..Time.current) }
    end

    trait :old do
      created_at { rand(30.days.ago..10.days.ago) }
    end

    trait :with_count do
      transient do
        download_count { 1 }
      end

      count { download_count }
    end
  end
end
