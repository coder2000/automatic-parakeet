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
require "rails_helper"

RSpec.describe IndiepadConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  describe ".defaults" do
    it "loads defaults from config/indiepad.yml" do
      defaults = described_class.defaults
      expect(defaults).to include(:default, :keynames, :keycodes)
      expect(defaults[:default]).to be_a(Hash)
      expect(defaults[:keynames]).to be_a(Hash)
      expect(defaults[:keycodes]).to be_a(Hash)
    end
  end

  describe "validations" do
    let(:game) { create(:game, with_download_link: true) }
    subject(:config) { build(:indiepad_config, game: game) }

    # Ensure an existing record is present for the uniqueness matcher
    before { create(:indiepad_config, game: create(:game, with_download_link: true)) }

    it { is_expected.to validate_uniqueness_of(:game) }

    it "limits top-level keys to default, keynames, keycodes" do
      config.data = config.data.merge(extra: {})
      expect(config).not_to be_valid
      expect(config.errors[:data].join).to match(/unknown keys/i)
    end

    it "requires integer values in nested hashes" do
      # data is JSON-like; ensure we use string keys when mutating
      config.data["default"]["left"] = "37"
      expect(config).not_to be_valid
      expect(config.errors[:data].join).to match(/values must be integers/i)
    end
  end
end
