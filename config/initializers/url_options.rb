# URL configuration for consistent link generation across environments
Rails.application.configure do
  if Rails.env.production?
    # Production: Use utilsawesome.com with HTTPS
    config.action_controller.default_url_options = {
      host: Rails.application.config.app_domain,
      protocol: "https"
    }
    config.action_mailer.default_url_options = {
      host: Rails.application.config.app_domain,
      protocol: "https"
    }
  elsif Rails.env.development?
    # Development: Use localhost with HTTP
    config.action_controller.default_url_options = {
      host: "localhost",
      port: 3000,
      protocol: "http"
    }
    config.action_mailer.default_url_options = {
      host: "localhost",
      port: 3000,
      protocol: "http"
    }
  end
end

# Also configure at the application level
Rails.application.routes.default_url_options = Rails.application.config.action_controller.default_url_options || {}
