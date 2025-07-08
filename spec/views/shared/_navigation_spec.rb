require 'rails_helper'

RSpec.describe "shared/_navigation", type: :view do

  context "when user is staff" do
    let(:user) { create(:user, staff: true, given_name: "Staff User") }

    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(user)
    end

    it "displays admin link" do
      render
      expect(rendered).to have_link("Admin", href: admin_root_path)
    end
  end

  context "when user is not staff" do
    let(:user) { create(:user, staff: false, given_name: "Regular User") }

    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(user)
    end

    it "does not display admin link" do
      render
      expect(rendered).not_to have_link("Admin")
    end
  end

  context "when user is not signed in" do
    before do
      allow(view).to receive(:user_signed_in?).and_return(false)
      allow(view).to receive(:current_user).and_return(nil)
    end

    it "does not display admin link" do
      render
      expect(rendered).not_to have_link("Admin")
    end
  end
end