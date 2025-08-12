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
require 'rails_helper'

RSpec.describe IndiepadConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
