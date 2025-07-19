# 📡 Universal Links API Documentation

## Overview
This document outlines the internal API structure and potential REST API endpoints for the Universal Links application.

## 🔗 Core Endpoints

### **Dynamic Links Management**

#### **List All Links**
```
GET /dynamic_links
Content-Type: application/json
```

**Response:**
```json
{
  "links": [
    {
      "id": 1,
      "title": "My Awesome App",
      "short_code": "abc123",
      "short_url": "https://utilsawesome.com/abc123",
      "target_url": "https://myapp.com/welcome",
      "description": "Welcome to our app",
      "active": true,
      "analytics_enabled": true,
      "total_clicks": 1250,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-16T14:20:00Z",
      "created_by": "Marketing Team",
      "social_meta": {
        "title": "Download My Awesome App",
        "description": "The best app for productivity",
        "image_url": "https://example.com/og-image.png"
      },
      "configurations": {
        "ios": {
          "app_store_id": "123456789",
          "bundle_identifier": "com.example.myapp",
          "custom_scheme": "myapp",
          "app_store_url": "https://apps.apple.com/app/id123456789"
        },
        "android": {
          "package_name": "com.example.myapp",
          "custom_scheme": "myapp",
          "play_store_url": "https://play.google.com/store/apps/details?id=com.example.myapp"
        },
        "web": {
          "desktop_url": "https://myapp.com/desktop",
          "fallback_url": "https://myapp.com"
        }
      }
    }
  ],
  "meta": {
    "total_count": 15,
    "page": 1,
    "per_page": 10
  }
}
```

#### **Create New Link**
```
POST /dynamic_links
Content-Type: application/json
```

**Request Body:**
```json
{
  "dynamic_link": {
    "title": "New Product Launch",
    "description": "Check out our latest product",
    "target_url": "https://mycompany.com/new-product",
    "short_code": "launch2024",
    "active": true,
    "analytics_enabled": true,
    "enable_utm_tracking": true,
    "enable_device_params": true,
    "auto_params": {
      "campaign": "winter_sale",
      "source": "email"
    },
    "social_title": "🚀 New Product Launch!",
    "social_description": "Revolutionary product changing everything",
    "social_image_url": "https://mycompany.com/product-image.jpg",
    "ios_config_attributes": {
      "app_store_id": "987654321",
      "bundle_identifier": "com.mycompany.app",
      "custom_scheme": "mycompany",
      "app_store_url": "https://apps.apple.com/app/id987654321"
    },
    "android_config_attributes": {
      "package_name": "com.mycompany.app",
      "custom_scheme": "mycompany",
      "play_store_url": "https://play.google.com/store/apps/details?id=com.mycompany.app"
    },
    "web_config_attributes": {
      "desktop_url": "https://mycompany.com/desktop-landing",
      "fallback_url": "https://mycompany.com/mobile-landing"
    }
  }
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Dynamic link created successfully",
  "data": {
    "id": 16,
    "short_url": "https://utilsawesome.com/launch2024",
    "short_code": "launch2024",
    // ... full link object
  }
}
```

#### **Update Link**
```
PATCH /dynamic_links/:id
Content-Type: application/json
```

#### **Delete Link**
```
DELETE /dynamic_links/:id
```

#### **Get Link Details**
```
GET /dynamic_links/:id
```

#### **Toggle Link Status**
```
PATCH /dynamic_links/:id/toggle_active
```

### **📊 Analytics Endpoints**

#### **Link Analytics Overview**
```
GET /dynamic_links/:id/analytics
```

**Response:**
```json
{
  "link": {
    "id": 1,
    "title": "My Awesome App",
    "short_code": "abc123"
  },
  "metrics": {
    "total_clicks": 1250,
    "clicks_last_30_days": 450,
    "clicks_last_7_days": 125,
    "clicks_today": 18,
    "unique_platforms": 3
  },
  "time_series": {
    "clicks_by_day": {
      "2024-01-01": 45,
      "2024-01-02": 52,
      "2024-01-03": 38,
      // ... last 30 days
    }
  },
  "breakdowns": {
    "by_platform": {
      "smartphone": 680,
      "desktop": 420,
      "tablet": 150
    },
    "by_os": {
      "iOS": 380,
      "Android": 300,
      "Windows": 320,
      "macOS": 100,
      "Linux": 150
    },
    "by_browser": {
      "Safari": 350,
      "Chrome": 450,
      "Firefox": 250,
      "Edge": 200
    },
    "by_country": {
      "US": 500,
      "CA": 200,
      "GB": 150,
      "DE": 100,
      "Other": 300
    }
  },
  "recent_clicks": [
    {
      "id": 5432,
      "device_type": "smartphone",
      "os_name": "iOS",
      "os_version": "15.6",
      "browser_name": "Safari",
      "country": "US",
      "clicked_at": "2024-01-16T14:30:00Z",
      "ip_address": "192.168.1.100",
      "referer": "https://twitter.com"
    }
    // ... more recent clicks
  ]
}
```

#### **Aggregate Analytics**
```
GET /analytics/summary
```

**Response:**
```json
{
  "overview": {
    "total_links": 25,
    "total_clicks": 15750,
    "active_links": 22,
    "clicks_today": 245,
    "links_created_this_month": 8
  },
  "top_performing_links": [
    {
      "id": 1,
      "title": "Main App Download",
      "short_code": "app",
      "total_clicks": 5420,
      "clicks_last_7_days": 380
    }
    // ... top 10 links
  ],
  "platform_distribution": {
    "smartphone": 8500,
    "desktop": 5250,
    "tablet": 2000
  },
  "geographic_distribution": {
    "US": 7500,
    "CA": 2000,
    "GB": 1500,
    "DE": 1200,
    "Other": 3550
  }
}
```

### **🔗 Link Redirection**

#### **Smart Redirect**
```
GET /:short_code
User-Agent: [Browser/App User Agent]
Accept: text/html
```

**Process Flow:**
1. **Link Lookup**: Find active link by short_code
2. **Device Detection**: Analyze User-Agent for platform/capabilities  
3. **Strategy Selection**: Choose optimal redirect strategy
4. **Analytics Tracking**: Record click data (if enabled)
5. **Parameter Injection**: Add UTM/device/custom parameters
6. **Redirect Execution**: Send user to appropriate destination

**Response Types:**

**Direct Redirect (Desktop/Simple Cases):**
```
HTTP/1.1 301 Moved Permanently
Location: https://myapp.com/welcome?utm_source=dynamic_link&utm_medium=referral
```

**Smart Redirect Page (iOS/Android with App Support):**
```html
<!DOCTYPE html>
<html>
<head>
  <title>Opening My Awesome App...</title>
  <meta property="og:title" content="Download My Awesome App">
  <!-- Social meta tags -->
</head>
<body>
  <script>
    // Intelligent deep linking JavaScript
    // Attempts Universal Links, App Links, custom schemes
    // Provides fallback options after timeout
  </script>
</body>
</html>
```

### **🔍 Search & Filtering**

#### **Search Links**
```
GET /dynamic_links/search?q=:query&platform=:platform&status=:status
```

**Parameters:**
- `q`: Search query (title, description, short_code)
- `platform`: Filter by platform (ios, android, web)
- `status`: Filter by status (active, inactive)
- `created_by`: Filter by creator
- `date_from`, `date_to`: Date range filtering

## 🛡️ Authentication & Security

### **API Authentication (Future)**
```
Authorization: Bearer <api_token>
Content-Type: application/json
```

### **Rate Limiting**
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 995
X-RateLimit-Reset: 1642781400
```

### **Error Responses**
```json
{
  "status": "error",
  "message": "Link not found",
  "error_code": "LINK_NOT_FOUND",
  "details": {
    "short_code": "invalid123"
  }
}
```

## 📱 Device Detection API

### **Device Info Endpoint**
```
GET /api/device_info
User-Agent: [Browser User Agent]
```

**Response:**
```json
{
  "device_info": {
    "device_type": "smartphone",
    "os_name": "iOS",
    "os_version": "15.6.1",
    "browser_name": "Safari",
    "browser_version": "15.6",
    "is_mobile": true,
    "is_tablet": false,
    "is_desktop": false,
    "is_ios": true,
    "is_android": false,
    "supports_universal_links": true,
    "supports_app_links": false,
    "recommended_strategy": "universal_link_with_fallback",
    "fingerprint": "a1b2c3d4e5f6g7h8"
  }
}
```

## 🎯 Webhook Integration (Future)

### **Event Types**
- `link.created`: New link created
- `link.updated`: Link modified
- `link.clicked`: Link received a click
- `link.analytics.milestone`: Click milestones (100, 1000, etc.)

### **Webhook Payload**
```json
{
  "event": "link.clicked",
  "timestamp": "2024-01-16T14:30:00Z",
  "data": {
    "link": {
      "id": 1,
      "short_code": "abc123",
      "title": "My Awesome App"
    },
    "click": {
      "device_type": "smartphone",
      "os_name": "iOS",
      "country": "US",
      "referer": "https://twitter.com"
    }
  }
}
```

## 🔧 Configuration API

### **App Settings**
```
GET /api/settings
```

```json
{
  "settings": {
    "app_domain": "utilsawesome.com",
    "default_link_expiry": null,
    "analytics_retention_days": 365,
    "max_links_per_user": null,
    "custom_domains": ["links.mycompany.com"],
    "features": {
      "bulk_operations": true,
      "custom_parameters": true,
      "webhooks": false,
      "api_access": false
    }
  }
}
```

## 📊 Bulk Operations API (Future)

### **Bulk Link Creation**
```
POST /api/bulk/links
```

**Request:**
```json
{
  "links": [
    {
      "title": "Product A",
      "target_url": "https://mystore.com/product-a",
      "short_code": "prod-a"
    },
    {
      "title": "Product B", 
      "target_url": "https://mystore.com/product-b",
      "short_code": "prod-b"
    }
  ],
  "default_config": {
    "analytics_enabled": true,
    "enable_utm_tracking": true
  }
}
```

### **Bulk Analytics Export**
```
GET /api/bulk/analytics/export?format=csv&date_from=2024-01-01&date_to=2024-01-31
```

## 🔄 Import/Export API

### **Export Links**
```
GET /api/export/links?format=json
```

### **Import Links**
```
POST /api/import/links
Content-Type: multipart/form-data
```

---

## 📚 SDK Examples (Future)

### **Ruby SDK**
```ruby
client = UniversalLinks::Client.new(api_token: 'your_token')

# Create link
link = client.links.create(
  title: "My App",
  target_url: "https://myapp.com",
  ios_config: {
    app_store_id: "123456789",
    bundle_identifier: "com.example.app"
  }
)

# Get analytics
analytics = client.analytics.get(link.id)
```

### **JavaScript SDK**
```javascript
const client = new UniversalLinksClient('your_token');

// Create link
const link = await client.links.create({
  title: 'My App',
  target_url: 'https://myapp.com',
  ios_config: {
    app_store_id: '123456789',
    bundle_identifier: 'com.example.app'
  }
});

// Get analytics
const analytics = await client.analytics.get(link.id);
```

This API documentation provides a comprehensive overview of the current and planned API capabilities for the Universal Links application. 