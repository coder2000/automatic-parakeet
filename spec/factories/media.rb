# == Schema Information
#
# Table name: media
#
#  id            :bigint           not null, primary key
#  description   :text
#  media_type    :string           not null
#  mediable_type :string           not null
#  position      :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  mediable_id   :bigint           not null
#
# Indexes
#
#  index_media_on_mediable                                      (mediable_type,mediable_id)
#  index_media_on_mediable_type_and_mediable_id_and_media_type  (mediable_type,mediable_id,media_type)
#  index_media_on_mediable_type_and_mediable_id_and_position    (mediable_type,mediable_id,position)
#
FactoryBot.define do
  factory :medium do
    association :mediable, factory: :game
    media_type { "screenshot" }
    title { Faker::Lorem.words(number: 2).join(" ").titleize }
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
      media_type { "screenshot" }
      title { "Game Screenshot" }
    end

    trait :video do
      media_type { "video" }
      title { "Game Video" }
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
