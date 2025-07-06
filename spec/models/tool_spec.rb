# == Schema Information
#
# Table name: tools
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tools_on_name  (name) UNIQUE
#

require 'rails_helper'

RSpec.describe Tool, type: :model do
  subject(:tool) { build(:tool) }

  it 'is valid with valid attributes' do
    expect(tool).to be_valid
  end

  it 'requires a name' do
    tool.name = nil
    expect(tool).not_to be_valid
  end

  it 'requires a unique name' do
    create(:tool, name: tool.name)
    expect(tool).not_to be_valid
  end

  it 'has many games' do
    assoc = described_class.reflect_on_association(:games)
    expect(assoc.macro).to eq :has_many
  end
end
