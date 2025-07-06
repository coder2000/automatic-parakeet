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

  it 'is valid with valid attributes' do
    expect(game).to be_valid
  end

  it 'requires a name' do
    game.name = nil
    expect(game).not_to be_valid
  end

  it 'requires a description' do
    game.description = nil
    expect(game).not_to be_valid
  end

  it 'belongs to a user' do
    expect(game.user).to be_a(User)
  end

  it 'belongs to a genre' do
    expect(game.genre).to be_a(Genre)
  end

  it 'belongs to a tool' do
    expect(game.tool).to be_a(Tool)
  end

  it 'has many download_links' do
    assoc = described_class.reflect_on_association(:download_links)
    expect(assoc.macro).to eq :has_many
  end

  it 'uses friendly_id for slug' do
    expect(game.slug).to eq(game.name.parameterize)
  end

  it 'defaults release_type to complete' do
    expect(game.release_type).to eq('complete')
  end
end
