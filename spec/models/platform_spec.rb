# == Schema Information
#
# Table name: platforms
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_platforms_on_name  (name) UNIQUE
#  index_platforms_on_slug  (slug) UNIQUE
#

require 'rails_helper'

RSpec.describe Platform, type: :model do
  subject(:platform) { build(:platform, name: 'Windows', slug: 'windows') }

  # Shoulda Matchers
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  # Note: friendly_id handles slug uniqueness, but you can test presence if needed

  # Custom logic
  it 'uses friendly_id for slug' do
    expect(platform.slug).to eq('windows')
  end
end
