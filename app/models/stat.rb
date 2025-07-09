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
class Stat < ApplicationRecord
  belongs_to :game

  validates :game_id, uniqueness: {scope: :created_at}

  scope :today_by_game_id, ->(game_id) { where(game_id: game_id, created_at: Time.zone.today) }

  def self.create_or_increment!(game_id, counters = {})
    query = today_by_game_id(game_id)
    stat = query.first_or_create!
    update_counters stat.id, counters
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    update_counters query.pluck(:id), counters
  end
end
