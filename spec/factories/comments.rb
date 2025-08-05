# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  parent_id  :bigint
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_game_id                   (game_id)
#  index_comments_on_game_id_and_created_at    (game_id,created_at)
#  index_comments_on_parent_id                 (parent_id)
#  index_comments_on_parent_id_and_created_at  (parent_id,created_at)
#  index_comments_on_user_id                   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (parent_id => comments.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.paragraph(sentence_count: 3) }
    association :user
    association :game
    parent { nil }

    trait :reply do
      association :parent, factory: :comment
    end

    trait :long_content do
      content { Faker::Lorem.paragraph(sentence_count: 20) }
    end

    trait :short_content do
      content { "This is a short comment but still valid length" }
    end

    trait :with_link do
      content { "Check out this cool game at https://example.com" }
    end

    trait :duplicate_content do
      content { "This is a duplicate comment" }
    end

    trait :old do
      created_at { 1.hour.ago }
    end

    trait :recent do
      created_at { 1.minute.ago }
    end
  end
end
