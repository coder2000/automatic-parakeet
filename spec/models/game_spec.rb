# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  adult_content :boolean          default(FALSE)
#  description   :text             not null
#  name          :string           not null
#  rating_abs    :float            default(0.0), not null
#  rating_avg    :float            default(0.0), not null
#  rating_count  :integer          default(0), not null
#  release_type  :integer          default("complete"), not null
#  slug          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  genre_id      :bigint
#  tool_id       :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_games_on_genre_id  (genre_id)
#  index_games_on_tool_id   (tool_id)
#  index_games_on_user_id   (user_id)
#

require 'rails_helper'

RSpec.describe Game, type: :model do
  subject(:game) { build(:game) }

  # Shoulda Matchers
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:genre) }
  it { is_expected.to belong_to(:tool) }
  it { is_expected.to have_many(:download_links).dependent(:destroy) }

  it { is_expected.to have_many(:activities).dependent(:destroy) }


  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }



  # Custom logic specs (non-shoulda)
  it 'uses friendly_id for slug' do
    expect(game.slug).to eq(game.name.parameterize)
  end

  it 'defaults release_type to complete' do
    expect(game.release_type).to eq('complete')
  end
end
