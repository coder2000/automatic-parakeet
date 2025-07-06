# == Schema Information
#
# Table name: genres
#
#  id         :bigint           not null, primary key
#  key        :string           default(""), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_genres_on_key   (key) UNIQUE
#  index_genres_on_name  (name) UNIQUE
#

require 'rails_helper'

RSpec.describe Genre, type: :model do
  subject(:genre) { build(:genre) }

  it 'is valid with valid attributes' do
    expect(genre).to be_valid
  end

  it 'requires a key' do
    genre.key = nil
    expect(genre).not_to be_valid
  end

  it 'requires a unique key' do
    create(:genre, key: genre.key)
    expect(genre).not_to be_valid
  end

  it 'requires a name' do
    genre.name = nil
    expect(genre).not_to be_valid
  end

  it 'has many games' do
    assoc = described_class.reflect_on_association(:games)
    expect(assoc.macro).to eq :has_many
  end

  it 'returns translated_name' do
    expect(genre.translated_name).to eq('Action')
  end
end
