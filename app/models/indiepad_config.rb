# == Schema Information
#
# Table name: indiepad_configs
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#
# Indexes
#
#  index_indiepad_configs_on_game_id  (game_id)
#
class IndiepadConfig < ApplicationRecord
  belongs_to :game

  validates :data, length: {maximum: 4}
  validates :game, uniqueness: true
end
