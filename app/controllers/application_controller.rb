class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Temporarily disabled Prosopite due to compatibility issue
  # unless Rails.env.production?
  #   around_action :n_plus_one_detection

  #   def n_plus_one_detection
  #     Prosopite.scan
  #     yield
  #   ensure
  #     Prosopite.finish
  #   end
  # end

  private

  # Set locale from params, user, session, or default
  def set_locale
    I18n.locale = extract_locale_from_params || current_user_locale || session[:locale] || I18n.default_locale
  end

  # Permit username and email for Devise sign up and account update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email])
  end

  # Extract locale from URL params (e.g., /en/..., /es/...)
  def extract_locale_from_params
    locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil
  end

  # Get locale from current_user if available
  def current_user_locale
    current_user&.preferred_locale if respond_to?(:current_user)
  end

  # Ensure locale param is added to all generated URLs
  def default_url_options
    {locale: I18n.locale}
  end

  # Only allow staff users to access ActiveAdmin
  def authenticate_staff_user!
    authenticate_user!
    unless current_user&.staff?
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
