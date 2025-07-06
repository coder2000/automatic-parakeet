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

  it 'is valid with valid attributes' do
    expect(platform).to be_valid
  end

  it 'requires a name' do
    platform.name = nil
    expect(platform).not_to be_valid
  end

  it 'requires a unique name' do
    create(:platform, name: platform.name)
    expect(platform).not_to be_valid
  end

  it 'uses friendly_id for slug' do
    expect(platform.slug).to eq('windows')
  end
end
