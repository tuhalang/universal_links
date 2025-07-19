# URL configuration for consistent link generation across environments
Rails.application.configure do
  if Rails.env.production?
    # Production: Force use of utilsawesome.com with HTTPS (for nginx proxy)
    config.action_controller.default_url_options = {
      host: "utilsawesome.com",
      protocol: "https"
    }
    config.action_mailer.default_url_options = {
      host: "utilsawesome.com",
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

# Ensure URL helpers use the correct domain in production behind nginx proxy
Rails.application.routes.default_url_options = if Rails.env.production?
  { host: "utilsawesome.com", protocol: "https" }
else
  Rails.application.config.action_controller.default_url_options || {}
end
