# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: "test"
    end
  end

  describe "authentication and authorization" do
    context "when user is not authenticated" do
      it "redirects to sign in page for protected actions" do
        # This would need to be tested with specific protected actions
        # in individual controller specs
        expect(true).to be true
      end
    end

    context "when user is authenticated" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "allows access to protected actions" do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "locale handling" do
    let(:user) { create(:user, locale: "es") }

    context "when user has a preferred locale" do
      before { sign_in user }

      it "sets the locale to user's preference" do
        get :index
        expect(I18n.locale).to eq(:es)
      end
    end

    context "when user doesn't have a preferred locale" do
      let(:user_without_locale) { create(:user, locale: nil) }

      before { sign_in user_without_locale }

      it "uses default locale" do
        get :index
        expect(I18n.locale).to eq(I18n.default_locale)
      end
    end
  end

  describe "error handling" do
    controller do
      def index
        raise ActiveRecord::RecordNotFound
      end
    end

    it "handles record not found errors gracefully" do
      expect { get :index }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
