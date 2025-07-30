# == Schema Information
#
# Table name: media
#
#  id            :bigint           not null, primary key
#  description   :text
#  media_type    :integer          default(NULL), not null
#  mediable_type :string           not null
#  position      :integer          default(0)
#  youtube_url   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  mediable_id   :bigint           not null
#
# Indexes
#
#  index_media_on_mediable                                    (mediable_type,mediable_id)
#  index_media_on_mediable_type_and_mediable_id_and_position  (mediable_type,mediable_id,position)
#
FactoryBot.define do
  factory :medium do
    association :mediable, factory: :game
    media_type { "screenshot" }
    description { Faker::Lorem.sentence }
    position { 0 }

    after(:build) do |medium|
      # Create a test file attachment for screenshots
      if medium.screenshot?
        medium.file.attach(
          io: StringIO.new("fake image data"),
          filename: "test_screenshot.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :screenshot do
      media_type { "screenshot" }
    end

    trait :video do
      media_type { "video" }
      youtube_url { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
      
      after(:build) do |medium|
        # Videos don't attach files, they use youtube_url
        medium.file.detach if medium.file.attached?
      end
    end

    trait :with_position do |position_value = 1|
      position { position_value }
    end

    trait :without_description do
      description { nil }
    end
  end
end
