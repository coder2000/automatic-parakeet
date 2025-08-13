# == Schema Information
#
# Table name: media
#
#  id            :bigint           not null, primary key
#  description   :text
#  media_type    :integer          default("screenshot"), not null
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
      # Create a real in-memory image attachment for screenshots so variants can process
      if medium.screenshot?
        # 1x1 transparent PNG
        base64_png = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/xcAAoMBgQp9jS8AAAAASUVORK5CYII="
        io = StringIO.new(Base64.decode64(base64_png))
        medium.file.attach(
          io: io,
          filename: "test.png",
          content_type: "image/png"
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
