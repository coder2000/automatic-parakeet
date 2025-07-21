require "rails_helper"

RSpec.describe "Point Integration", type: :model do
  let(:user) { create(:user, score: 0) }
  let(:game_owner) { create(:user, score: 0) }
  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }

  describe "Game creation points" do
    it "awards points when creating a game" do
      expect {
        create(:game, user: user, genre: genre, tool: tool)
      }.to change { user.reload.score }.by(50)
    end

    it "removes points when deleting a game" do
      game = create(:game, user: user, genre: genre, tool: tool)
      user.reload # Refresh to get the awarded points

      expect {
        game.destroy
      }.to change { user.reload.score }.by(-50)
    end
  end

  describe "Following points" do
    let(:game) { create(:game, user: game_owner, genre: genre, tool: tool) }

    it "awards points when following a game" do
      expect {
        create(:following, user: user, game: game)
      }.to change { user.reload.score }.by(5)
    end

    it "removes points when unfollowing a game" do
      following = create(:following, user: user, game: game)
      user.reload # Refresh to get the awarded points

      expect {
        following.destroy
      }.to change { user.reload.score }.by(-5)
    end
  end

  describe "Rating points" do
    let!(:game) { create(:game, user: game_owner, genre: genre, tool: tool) }

    it "awards points to both rater and game owner" do
      # Reset scores to isolate rating points only
      user.update!(score: 0)
      game_owner.update!(score: 0)

      create(:rating, user: user, game: game, rating: 4.5)

      expect(user.reload.score).to eq(10)  # Points for rating
      expect(game_owner.reload.score).to eq(5)  # Points for receiving rating
    end

    it "removes points when rating is deleted" do
      rating = create(:rating, user: user, game: game, rating: 4.5)
      user.reload
      game_owner.reload

      expect {
        rating.destroy
      }.to change { user.reload.score }.by(-10)
        .and change { game_owner.reload.score }.by(-5)
    end
  end

  describe "Download points" do
    let!(:game) { create(:game, user: game_owner, genre: genre, tool: tool) }
    let(:download_link) { create(:download_link, game: game) }

    it "awards points to game owner when game is downloaded" do
      # Reset game_owner score after game creation to isolate download points
      game_owner.update!(score: 0)

      expect {
        create(:download, download_link: download_link, user: user)
      }.to change { game_owner.reload.score }.by(2)
    end
  end

  describe "News points" do
    let(:game) { create(:game, user: game_owner, genre: genre, tool: tool) }

    it "awards points when posting news" do
      expect {
        create(:news, user: user, game: game, text: "Game update!")
      }.to change { user.reload.score }.by(15)
    end

    it "removes points when news is deleted" do
      news = create(:news, user: user, game: game, text: "Game update!")
      user.reload

      expect {
        news.destroy
      }.to change { user.reload.score }.by(-15)
    end
  end
end
