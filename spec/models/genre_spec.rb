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

require "rails_helper"

RSpec.describe Genre, type: :model do
  subject(:genre) { build(:genre) }

  # Shoulda Matchers
  it { is_expected.to have_many(:games) }
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:name) }

  # Custom logic
  it "returns translated_name" do
    expect(genre.translated_name).to eq("Action")
  end
end
