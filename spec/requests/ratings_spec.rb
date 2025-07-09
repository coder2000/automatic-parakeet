require "rails_helper"

RSpec.describe "Ratings", type: :request do
  let(:user) { create(:user) }
  let(:game_owner) { create(:user) }
  let(:game) { create(:game, user: game_owner) }
  let(:other_user) { create(:user) }

  describe "POST /games/:game_id/ratings" do
    context "when user is signed in" do
      before do
        login_as(user, scope: :user)
      end

      it "creates a new rating" do
        # Ensure clean state
        Rating.destroy_all
        expect {
          post game_ratings_path(game), params: {rating: {rating: 5}}
        }.to change(Rating, :count).by(1)
        expect(response).to redirect_to(game)
        expect(flash[:notice]).to eq("Thank you for rating this game!")
      end

      # Debug test removed

      # Debug test removed

      it "test with inline game creation" do
        # Create game and user within the test to avoid database_cleaner issues
        test_user = create(:user)
        test_game_owner = create(:user)
        test_game = create(:game, user: test_game_owner)
        sign_in test_user
        expect {
          post game_ratings_path(test_game), params: {rating: {rating: 5}}
        }.to change(Rating, :count).by(1)
        expect(response).to redirect_to(test_game)
      end

      it "updates game rating statistics" do
        post game_ratings_path(game), params: {rating: {rating: 4}}
        game.reload
        expect(game.rating_avg).to eq(4.0)
        expect(game.rating_count).to eq(1)
      end

      it "prevents duplicate ratings from same user" do
        create(:rating, user: user, game: game, rating: 3)

        expect {
          post game_ratings_path(game), params: {rating: {rating: 5}}
        }.not_to change(Rating, :count)
      end

      it "prevents rating own game" do
        own_game = create(:game, user: user)

        post game_ratings_path(own_game), params: {rating: {rating: 5}}

        expect(Rating.where(user: user, game: own_game)).to be_empty
      end
    end

    context "when user is not signed in" do
      before do
        logout(:user)
      end

      it "redirects to sign in" do
        post game_ratings_path(game), params: {rating: {rating: 5}}
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # PATCH/DELETE for ratings are not supported; ratings are immutable except by deleting the game itself.
end
