# Ensure route helper methods like games_path/root_path are available in specs

module RouteHelperMethods
  def route_proxy
    @route_proxy ||= begin
      Rails.application.reload_routes!
      mod = Rails.application.routes.url_helpers
      Class.new do
        include mod
        def default_url_options
          {locale: :en}
        end
      end.new
    end
  end

  def method_missing(method_name, *args, &block)
    route_proxy.public_send(method_name, *args, &block)
  rescue => e
    raise e unless e.is_a?(NoMethodError) || e.is_a?(NameError)
    super
  end

  def respond_to_missing?(method_name, include_private = false)
    route_proxy.respond_to?(method_name, include_private) || super
  end
end

RSpec.configure do |config|
  # Include route helper delegation in all example groups
  config.include RouteHelperMethods

  # Extend the view context with helpers and provide url_options
  config.before(:each, type: :view) do
    view.extend RouteHelperMethods
    # Ensure locale is set for locale-scoped routes
    allow(view).to receive(:url_options).and_return({locale: :en})
  end
end
