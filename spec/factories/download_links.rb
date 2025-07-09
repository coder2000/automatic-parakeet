FactoryBot.define do
  factory :download_link do
    association :game
    label { "Download Link" }
    url { "https://example.com/download.zip" }

    trait :with_platforms do
      after(:create) do |download_link|
        download_link.platforms << create(:platform)
      end
    end
  end
end
