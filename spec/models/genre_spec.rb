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
require 'rails_helper'

RSpec.describe Genre, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
