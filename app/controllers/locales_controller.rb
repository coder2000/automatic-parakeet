class LocalesController < ApplicationController
  def update
    locale = params[:locale]

    if I18n.available_locales.map(&:to_s).include?(locale)
      # Update user's preferred locale if signed in
      if user_signed_in?
        current_user.update(locale: locale)
      end

      # Store locale in session as fallback
      session[:locale] = locale

      redirect_back(fallback_location: root_path)
    else
      redirect_back(fallback_location: root_path, alert: t("flash.invalid_locale"))
    end
  end
end
