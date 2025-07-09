# == Schema Information
#
# Table name: followings
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_followings_on_game_id  (game_id)
#  index_followings_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :following do
    association :user
    association :game

    trait :with_activity do
      after(:create) do |following|
        following.create_activity(:follow)
      end
    end
  end
end
