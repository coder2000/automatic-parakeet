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
FactoryBot.define do
  factory :tool do
    sequence(:name) { |n| "#{Faker::Game.platform} #{n}" }
  end
end
