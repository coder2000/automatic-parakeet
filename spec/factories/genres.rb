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
FactoryBot.define do
  factory :genre do
    sequence(:key) { |n| "genre-key-#{n}" }
    sequence(:name) { |n| "GenreName#{n}" }

    # Allow explicit override for tests that expect specific values
    trait :action do
      key { "action" }
      name { "Action" }
    end
  end
end
