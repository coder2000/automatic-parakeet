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
class Tool < ApplicationRecord
  has_many :games, dependent: nil

  validates :name, presence: true, uniqueness: true

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[games]
  end
end
