# == Schema Information
#
# Table name: download_links
#
#  id         :bigint           not null, primary key
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#
# Indexes
#
#  index_download_links_on_game_id  (game_id)
#  index_download_links_on_url      (url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
FactoryBot.define do
  factory :download_link do
    association :game
    sequence(:label) { |n| "Download Link #{n}" }
    sequence(:url) { |n| "https://example.com/download#{n}.zip" }

    trait :with_platforms do
      after(:create) do |download_link|
        download_link.platforms << create(:platform)
      end
    end
  end
end
