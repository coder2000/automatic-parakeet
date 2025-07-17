FactoryBot.define do
  factory :medium do
    association :mediable, factory: :game
    media_type { 'screenshot' }
    title { Faker::Lorem.words(number: 2).join(' ').titleize }
    description { Faker::Lorem.sentence }
    position { 0 }

    after(:build) do |medium|
      # Create a test file attachment
      if medium.screenshot?
        medium.file.attach(
          io: StringIO.new("fake image data"),
          filename: "test_screenshot.jpg",
          content_type: "image/jpeg"
        )
      else
        medium.file.attach(
          io: StringIO.new("fake video data"),
          filename: "test_video.mp4",
          content_type: "video/mp4"
        )
      end
    end

    trait :screenshot do
      media_type { 'screenshot' }
      title { 'Game Screenshot' }
    end

    trait :video do
      media_type { 'video' }
      title { 'Game Video' }
    end

    trait :with_position do |position_value = 1|
      position { position_value }
    end

    trait :without_title do
      title { nil }
    end

    trait :without_description do
      description { nil }
    end
  end
end