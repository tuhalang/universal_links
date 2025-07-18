# Clear existing data
DynamicLink.destroy_all

puts "Creating sample dynamic links..."

# Sample 1: Complete multi-platform link
sample_app = DynamicLink.create!(
  title: "Sample Mobile App",
  description: "A sample mobile application with iOS and Android support",
  target_url: "https://example.com/app",
  social_title: "Download our amazing app!",
  social_description: "Experience the best mobile app for productivity and fun.",
  social_image_url: "https://via.placeholder.com/1200x630/4f46e5/white?text=Sample+App",
  active: true,
  analytics_enabled: true,
  created_by: "System"
)

sample_app.create_ios_config!(
  app_store_id: "123456789",
  bundle_identifier: "com.example.sampleapp",
  custom_scheme: "sampleapp",
  app_store_url: "https://apps.apple.com/app/sample-app/id123456789"
)

sample_app.create_android_config!(
  package_name: "com.example.sampleapp",
  custom_scheme: "sampleapp",
  play_store_url: "https://play.google.com/store/apps/details?id=com.example.sampleapp"
)

sample_app.create_web_config!(
  desktop_url: "https://sampleapp.com/web",
  fallback_url: "https://sampleapp.com"
)

# Sample 2: iOS-only app
ios_app = DynamicLink.create!(
  title: "iOS Exclusive App",
  description: "An exclusive iOS application",
  target_url: "https://example.com/ios-app",
  social_title: "iOS App",
  social_description: "Available exclusively on the App Store",
  active: true,
  analytics_enabled: true,
  created_by: "System"
)

ios_app.create_ios_config!(
  app_store_id: "987654321",
  bundle_identifier: "com.example.iosapp",
  custom_scheme: "iosapp"
)

# Sample 3: Web service link
web_service = DynamicLink.create!(
  title: "Web Service",
  description: "A web-based service with mobile-optimized experience",
  target_url: "https://webservice.example.com",
  social_title: "Amazing Web Service",
  social_description: "Access our powerful web service from any device",
  active: true,
  analytics_enabled: true,
  created_by: "System"
)

web_service.create_web_config!(
  desktop_url: "https://webservice.example.com/desktop",
  fallback_url: "https://webservice.example.com"
)

# Sample 4: Marketing campaign link
campaign_link = DynamicLink.create!(
  title: "Summer Campaign",
  description: "Special summer promotion campaign",
  target_url: "https://example.com/summer-sale",
  social_title: "🌞 Summer Sale - 50% Off!",
  social_description: "Don't miss our biggest sale of the year. Limited time offer!",
  social_image_url: "https://via.placeholder.com/1200x630/ff6b6b/white?text=Summer+Sale+50%25+Off",
  active: true,
  analytics_enabled: true,
  created_by: "Marketing Team"
)

# Sample 5: Facebook App Test Link
facebook_test = DynamicLink.create!(
  title: "Facebook App Test Link",
  description: "Test dynamic link for Facebook mobile app with smart platform detection",
  target_url: "https://www.facebook.com/profile.php?id=100000000000000",
  social_title: "Check out this profile on Facebook!",
  social_description: "Join the conversation and connect with friends on Facebook.",
  social_image_url: "https://www.facebook.com/images/fb_icon_325x325.png",
  active: true,
  analytics_enabled: true,
  created_by: "System - Facebook Test",
  enable_utm_tracking: true,
  enable_device_params: true
)

# iOS Configuration for Facebook
facebook_test.create_ios_config!(
  app_store_id: "284882215", # Facebook's actual App Store ID
  bundle_identifier: "com.facebook.Facebook",
  custom_scheme: "fb",
  app_store_url: "https://apps.apple.com/app/facebook/id284882215"
)

# Android Configuration for Facebook
facebook_test.create_android_config!(
  package_name: "com.facebook.katana", # Facebook's actual package name
  custom_scheme: "fb",
  play_store_url: "https://play.google.com/store/apps/details?id=com.facebook.katana"
)

# Web Configuration for Facebook
facebook_test.create_web_config!(
  desktop_url: "https://www.facebook.com",
  fallback_url: "https://www.facebook.com"
)

# Create some sample click data for analytics demonstration
puts "Creating sample analytics data..."

# Generate clicks for the past 30 days
(30.days.ago.to_date..Date.current).each do |date|
  # Random number of clicks per day (0-50)
  clicks_count = rand(0..50)

  clicks_count.times do
    # Random time during the day
    clicked_at = date.beginning_of_day + rand(24.hours.to_i).seconds

    # Random device types and platforms
    device_types = [ 'smartphone', 'tablet', 'desktop' ]
    os_names = [ 'iOS', 'Android', 'Windows', 'macOS', 'Linux' ]
    browsers = [ 'Safari', 'Chrome', 'Firefox', 'Edge' ]

    device_type = device_types.sample
    os_name = case device_type
    when 'smartphone', 'tablet'
                 [ 'iOS', 'Android' ].sample
    else
                 [ 'Windows', 'macOS', 'Linux' ].sample
    end

    browser_name = browsers.sample

    # Pick a random dynamic link
    dynamic_link = DynamicLink.order("RANDOM()").first

    dynamic_link.clicks.create!(
      user_agent: "Sample User Agent String",
      ip_address: "192.168.1.#{rand(1..254)}",
      referer: [ "https://google.com", "https://facebook.com", "https://twitter.com", nil ].sample,
      device_type: device_type,
      os_name: os_name,
      os_version: "#{rand(10..15)}.#{rand(0..9)}",
      browser_name: browser_name,
      browser_version: "#{rand(80..120)}.0",
      country: [ "US", "CA", "GB", "DE", "FR", "JP", "AU" ].sample,
      clicked_at: clicked_at
    )
  end
end

puts "✅ Created #{DynamicLink.count} dynamic links"
puts "✅ Created #{Click.count} sample clicks"
puts ""
puts "Sample links created:"
DynamicLink.all.each do |link|
  puts "📱 #{link.title} - #{link.short_url}"
end
