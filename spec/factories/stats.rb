# == Schema Information
#
# Table name: stats
#
#  id         :bigint           not null, primary key
#  downloads  :integer          default(0), not null
#  visits     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint
#
# Indexes
#
#  index_stats_on_game_id                 (game_id)
#  index_stats_on_game_id_and_created_at  (game_id,created_at) UNIQUE
#
FactoryBot.define do
  factory :stat do
    association :game
    downloads { 0 }
    visits { 0 }
    sequence(:created_at) { |n| Time.zone.now.beginning_of_day + n.seconds }

    trait :with_downloads do
      downloads { rand(1..100) }
    end

    trait :with_visits do
      visits { rand(1..500) }
    end

    trait :popular do
      downloads { rand(50..200) }
      visits { rand(200..1000) }
    end

    trait :yesterday do
      created_at { 1.day.ago }
    end

    trait :last_week do
      created_at { 1.week.ago }
    end
  end
end
