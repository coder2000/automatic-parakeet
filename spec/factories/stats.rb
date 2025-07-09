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
    
  end
end
