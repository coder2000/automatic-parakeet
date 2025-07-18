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
FactoryBot.define do
  factory :platform do
    sequence(:name) { |n| "Platform #{n}" }
    slug { name.parameterize }
  end
end
