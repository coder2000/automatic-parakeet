# == Schema Information
#
# Table name: news
#
#  id         :bigint           not null, primary key
#  text       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_news_on_game_id  (game_id)
#  index_news_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe News, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:game) { FactoryBot.create(:game) }

  before { NewsConfig.cooloff_interval = 1.hour }

  it 'allows first news post' do
    news = News.new(user: user, game: game, text: 'First!')
    expect(news).to be_valid
  end

  it 'prevents posting within cooloff interval' do
    FactoryBot.create(:news, user: user, game: game, text: 'First!')
    news = News.new(user: user, game: game, text: 'Second!')
    expect(news).not_to be_valid
    expect(news.errors[:base]).to include(/wait/i)
  end

  it 'allows posting after cooloff interval' do
    old_news = FactoryBot.create(:news, user: user, game: game, text: 'First!', created_at: 2.hours.ago)
    news = News.new(user: user, game: game, text: 'Second!')
    expect(news).to be_valid
  end
end
