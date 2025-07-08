# == Schema Information
#
# Table name: ratings
#
#  id         :bigint           not null, primary key
#  rating     :float            default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ratings_on_game_id              (game_id)
#  index_ratings_on_user_id              (user_id)
#  index_ratings_on_user_id_and_game_id  (user_id,game_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Rating, type: :model do
  subject { build(:rating) }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:game) }
  end

  describe "validations" do
    it { should validate_presence_of(:rating) }
    it { should validate_numericality_of(:rating).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:game) }
    it { should validate_uniqueness_of(:user).scoped_to(:game_id) }
  end
end
