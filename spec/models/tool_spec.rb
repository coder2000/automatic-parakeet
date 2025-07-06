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

  # Shoulda Matchers
  it { is_expected.to have_many(:games) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
