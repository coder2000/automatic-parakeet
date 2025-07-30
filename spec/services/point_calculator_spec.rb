require "rails_helper"

RSpec.describe PointCalculator, type: :service do
  let(:user) { create(:user, score: 100) }

  describe ".award_points" do
    it "awards points for a valid action" do
      expect {
        PointCalculator.award_points(user, :create_game)
      }.to change { user.reload.score }.by(50)
    end

    it "creates an activity record for the point award" do
      expect {
        PointCalculator.award_points(user, :follow_game)
      }.to change { PublicActivity::Activity.count }.by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("points.awarded")
      expect(activity.parameters[:action]).to eq("follow_game")
      expect(activity.parameters[:points]).to eq(5)
      expect(activity.parameters[:total_score]).to eq(105)
    end

    it "awards custom point amounts" do
      expect {
        PointCalculator.award_points(user, :custom_action, 25)
      }.to change { user.reload.score }.by(25)
    end

    it "does nothing for nil user" do
      expect {
        PointCalculator.award_points(nil, :create_game)
      }.not_to change { PublicActivity::Activity.count }
    end

    it "does nothing for invalid action" do
      expect {
        PointCalculator.award_points(user, :invalid_action)
      }.not_to change { user.reload.score }
    end
  end

  describe ".remove_points" do
    it "removes points for a valid action" do
      expect {
        PointCalculator.remove_points(user, :create_game)
      }.to change { user.reload.score }.by(-50)
    end

    it "does not let score go below 0" do
      user.update!(score: 10)
      expect {
        PointCalculator.remove_points(user, :create_game) # 50 points
      }.to change { user.reload.score }.from(10).to(0)
    end

    it "creates an activity record for the point removal" do
      expect {
        PointCalculator.remove_points(user, :follow_game)
      }.to change { PublicActivity::Activity.count }.by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("points.removed")
      expect(activity.parameters[:action]).to eq("follow_game")
      expect(activity.parameters[:points]).to eq(5)
    end
  end

  describe ".point_value_for" do
    it "returns correct point values" do
      expect(PointCalculator.point_value_for(:create_game)).to eq(50)
      expect(PointCalculator.point_value_for(:follow_game)).to eq(5)
      expect(PointCalculator.point_value_for(:rate_game)).to eq(10)
      expect(PointCalculator.point_value_for(:post_news)).to eq(15)
      expect(PointCalculator.point_value_for(:game_downloaded)).to eq(2)
      expect(PointCalculator.point_value_for(:game_rated)).to eq(5)
    end

    it "returns nil for invalid actions" do
      expect(PointCalculator.point_value_for(:invalid_action)).to be_nil
    end
  end
end
