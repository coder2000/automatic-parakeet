# == Schema Information
#
# Table name: games
#
#  id                :bigint           not null, primary key
#  adult_content     :boolean          default(FALSE)
#  author            :string
#  description       :text             not null
#  name              :string           not null
#  rating_abs        :float            default(0.0), not null
#  rating_avg        :float            default(0.0), not null
#  rating_count      :integer          default(0), not null
#  release_type      :integer          default("complete"), not null
#  screenshots_count :integer          default(0), not null
#  slug              :string           not null
#  videos_count      :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cover_image_id    :bigint
#  genre_id          :bigint
#  tool_id           :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_games_on_cover_image_id     (cover_image_id)
#  index_games_on_genre_id           (genre_id)
#  index_games_on_screenshots_count  (screenshots_count)
#  index_games_on_tool_id            (tool_id)
#  index_games_on_user_id            (user_id)
#  index_games_on_videos_count       (videos_count)
#
# Foreign Keys
#
#  fk_rails_...  (cover_image_id => media.id)
#
FactoryBot.define do
  factory :game do
    association :user
    association :genre
    association :tool
    sequence(:name) { |n| "Game #{n}" }
    description { Faker::Lorem.paragraph }
    release_type { :complete }
    sequence(:slug) { |n| "game-#{n}" }
    # Removed :key sequence, as Game does not have a key attribute
  end
end
