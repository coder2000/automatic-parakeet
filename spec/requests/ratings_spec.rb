require 'rails_helper'

RSpec.describe "Ratings", type: :request do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:other_user) { create(:user) }

  describe "POST /games/:game_id/ratings" do
    context "when user is signed in" do
      before { sign_in user }

      it "creates a new rating" do
        expect {
          post game_ratings_path(game), params: { rating: { rating: 5 } }
        }.to change(Rating, :count).by(1)
        
        expect(response).to redirect_to(game)
        expect(flash[:notice]).to eq('Thank you for rating this game!')
      end

      it "updates game rating statistics" do
        post game_ratings_path(game), params: { rating: { rating: 4 } }
        
        game.reload
        expect(game.rating_avg).to eq(4.0)
        expect(game.rating_count).to eq(1)
      end

      it "prevents duplicate ratings from same user" do
        create(:rating, user: user, game: game, rating: 3)
        
        expect {
          post game_ratings_path(game), params: { rating: { rating: 5 } }
        }.not_to change(Rating, :count)
      end

      it "prevents rating own game" do
        own_game = create(:game, user: user)
        
        post game_ratings_path(own_game), params: { rating: { rating: 5 } }
        
        expect(Rating.where(user: user, game: own_game)).to be_empty
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        post game_ratings_path(game), params: { rating: { rating: 5 } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /games/:game_id/ratings/:id" do
    let!(:rating) { create(:rating, user: user, game: game, rating: 3) }

    context "when user is signed in" do
      before { sign_in user }

      it "updates the rating" do
        patch game_rating_path(game, rating), params: { rating: { rating: 5 } }
        
        rating.reload
        expect(rating.rating).to eq(5)
        expect(response).to redirect_to(game)
      end

      it "updates game rating statistics" do
        patch game_rating_path(game, rating), params: { rating: { rating: 5 } }
        
        game.reload
        expect(game.rating_avg).to eq(5.0)
      end
    end

    context "when user tries to update someone else's rating" do
      before { sign_in other_user }

      it "returns not found" do
        patch game_rating_path(game, rating), params: { rating: { rating: 5 } }
        expect(response).to redirect_to(game)
        expect(flash[:alert]).to eq('Rating not found.')
      end
    end
  end

  describe "DELETE /games/:game_id/ratings/:id" do
    let!(:rating) { create(:rating, user: user, game: game, rating: 4) }

    context "when user is signed in" do
      before { sign_in user }

      it "destroys the rating" do
        expect {
          delete game_rating_path(game, rating)
        }.to change(Rating, :count).by(-1)
        
        expect(response).to redirect_to(game)
        expect(flash[:notice]).to eq('Your rating has been removed.')
      end

      it "updates game rating statistics" do
        # Add another rating to test average calculation
        create(:rating, user: other_user, game: game, rating: 2)
        
        delete game_rating_path(game, rating)
        
        game.reload
        expect(game.rating_avg).to eq(2.0)
        expect(game.rating_count).to eq(1)
      end
    end
  end
end