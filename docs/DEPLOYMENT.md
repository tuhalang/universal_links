# 🚀 Universal Links Deployment Guide

## Overview
This guide covers deploying the Universal Links application in various environments, from development to production.

## 🛠️ Requirements

### **System Requirements**
- **Ruby**: 3.2.0 or higher
- **Rails**: 8.0.2 or higher  
- **Database**: PostgreSQL 12+ 
- **Web Server**: Nginx (recommended) or Apache
- **Process Manager**: Systemd (Linux) or similar
- **SSL Certificate**: Required for HTTPS (Let's Encrypt recommended)

### **Recommended Server Specs**
- **CPU**: 2+ cores
- **RAM**: 4GB+ 
- **Storage**: 20GB+ SSD
- **Network**: 1Gbps connection
- **OS**: Ubuntu 20.04+ or CentOS 8+

## 🔧 Environment Setup

### **1. Development Environment**

#### **Local Setup**
```bash
# Clone repository
git clone https://github.com/tuhalang/universal_links.git
cd universal_links

# Install Ruby dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Install and build assets
rails assets:precompile

# Start development server
rails server
```

#### **Environment Variables**
```bash
# .env.development
RAILS_ENV=development
DATABASE_URL=postgresql://user:password@localhost/universal_links_development
APP_DOMAIN=localhost:3000
```

### **2. Production Environment**

#### **Server Preparation**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y postgresql postgresql-contrib nginx curl git build-essential

# Install rbenv and Ruby
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
rbenv install 3.2.0
rbenv global 3.2.0

# Install Bundler
gem install bundler
```

#### **Database Setup**
```bash
# Create PostgreSQL user and database
sudo -u postgres createuser -s rails
sudo -u postgres createdb universal_links_production
sudo -u postgres psql -c "ALTER USER rails PASSWORD 'secure_password';"
```

#### **Application Deployment**
```bash
# Clone to production directory
sudo git clone https://github.com/tuhalang/universal_links.git /root/universal_links
cd /root/universal_links

# Install gems
bundle install --deployment --without development test

# Setup environment file
cp .env.example .env.production
```

#### **Production Environment File**
```bash
# .env.production
RAILS_ENV=production
RACK_ENV=production
NODE_ENV=production

# Generate with: rails secret
SECRET_KEY_BASE=your_secret_key_base_here

# Database Configuration
DATABASE_URL=postgresql://rails:secure_password@localhost/universal_links_production

# Application Settings
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
FORCE_SSL=true

# Domain Configuration
APP_DOMAIN=utilsawesome.com
ALLOWED_HOSTS=utilsawesome.com,www.utilsawesome.com,localhost,127.0.0.1

# Performance Settings
WEB_CONCURRENCY=2
MAX_THREADS=5
PORT=3000

# Logging
LOG_LEVEL=info
TZ=UTC
```

#### **Database Migration**
```bash
# Run database setup
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails db:seed

# Precompile assets
RAILS_ENV=production rails assets:precompile
```

## 🔄 Systemd Service Setup

### **Create Service File**
```bash
sudo nano /etc/systemd/system/universal-links.service
```

#### **Service Configuration**
```ini
[Unit]
Description=Universal Links Rails Application
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/universal_links
Environment=RAILS_ENV=production
Environment=RACK_ENV=production
EnvironmentFile=-/root/universal_links/.env.production

# Database migration before start
ExecStartPre=/bin/bash -c 'cd /root/universal_links && /root/.rbenv/shims/bundle exec rails db:migrate RAILS_ENV=production'

# Start the Rails server
ExecStart=/root/.rbenv/shims/bundle exec rails server -e production -p 3000 -b 0.0.0.0

# Restart settings
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=universal-links

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/root/universal_links
ReadWritePaths=/tmp

[Install]
WantedBy=multi-user.target
```

### **Service Management**
```bash
# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable universal-links.service
sudo systemctl start universal-links.service

# Check status
sudo systemctl status universal-links.service

# View logs
sudo journalctl -u universal-links.service -f

# Restart service
sudo systemctl restart universal-links.service
```

## 🌐 Nginx Configuration

### **Create Nginx Site Configuration**
```bash
sudo nano /etc/nginx/sites-available/universal-links
```

#### **Nginx Configuration**
```nginx
upstream universal_links {
    server 127.0.0.1:3000 fail_timeout=0;
}

server {
    listen 80;
    server_name utilsawesome.com www.utilsawesome.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name utilsawesome.com www.utilsawesome.com;

    # SSL Configuration (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/utilsawesome.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/utilsawesome.com/privkey.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Document root and index
    root /root/universal_links/public;
    index index.html;

    # Asset caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Handle static files
    location ~ ^/(assets|packs)/ {
        gzip_static on;
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Try static files first, then proxy to Rails
    location / {
        try_files $uri $uri/index.html $uri.html @rails;
    }

    # Proxy to Rails application
    location @rails {
        proxy_pass http://universal_links;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_redirect off;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }

    # Error pages
    error_page 500 502 503 504 /500.html;
    error_page 404 /404.html;

    # Logs
    access_log /var/log/nginx/universal_links_access.log;
    error_log /var/log/nginx/universal_links_error.log;

    # Security
    location ~ /\. {
        deny all;
    }

    # Block common exploit attempts
    location ~* \.(aspx|php|jsp|cgi)$ {
        deny all;
    }
}
```

### **Enable Site and Restart Nginx**
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/universal-links /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

## 🔒 SSL Certificate Setup

### **Let's Encrypt with Certbot**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d utilsawesome.com -d www.utilsawesome.com

# Auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

### **Manual SSL Certificate**
```bash
# If using custom certificate
sudo mkdir -p /etc/ssl/certs/utilsawesome.com/
sudo cp your_certificate.crt /etc/ssl/certs/utilsawesome.com/
sudo cp your_private.key /etc/ssl/private/utilsawesome.com/
sudo chmod 600 /etc/ssl/private/utilsawesome.com/*
```

## 📊 Monitoring & Logging

### **Log Locations**
```bash
# Application logs (systemd)
sudo journalctl -u universal-links.service -f

# Nginx logs
sudo tail -f /var/log/nginx/universal_links_access.log
sudo tail -f /var/log/nginx/universal_links_error.log

# Rails logs (if file-based)
tail -f /root/universal_links/log/production.log
```

### **Health Check Endpoint**
```bash
# Application health check
curl https://utilsawesome.com/up

# Expected response
Status: 200 OK
```

### **Performance Monitoring**
```bash
# System resources
htop
free -h
df -h

# Network connections
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :443

# PostgreSQL performance
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

## 🔄 Backup & Recovery

### **Database Backup**
```bash
# Create backup script
sudo nano /root/backup-universal-links.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/universal_links"
DB_NAME="universal_links_production"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
sudo -u postgres pg_dump $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# Backup application files
tar -czf $BACKUP_DIR/app_backup_$DATE.tar.gz /root/universal_links

# Remove old backups (keep 30 days)
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
```

```bash
# Make executable
sudo chmod +x /root/backup-universal-links.sh

# Add to crontab for daily backups
sudo crontab -e
# Add: 0 2 * * * /root/backup-universal-links.sh
```

### **Recovery Process**
```bash
# Restore database
sudo -u postgres psql -c "DROP DATABASE IF EXISTS universal_links_production;"
sudo -u postgres psql -c "CREATE DATABASE universal_links_production;"
sudo -u postgres psql universal_links_production < /backup/universal_links/db_backup_20240101_020000.sql

# Restore application files
sudo systemctl stop universal-links
sudo tar -xzf /backup/universal_links/app_backup_20240101_020000.tar.gz -C /
sudo systemctl start universal-links
```

## 🚀 Deployment Automation

### **Deployment Script**
```bash
sudo nano /root/deploy-universal-links.sh
```

```bash
#!/bin/bash

APP_DIR="/root/universal_links"
BACKUP_DIR="/backup/universal_links"
DATE=$(date +%Y%m%d_%H%M%S)

echo "🚀 Starting deployment: $DATE"

# Create backup before deployment
echo "📦 Creating backup..."
sudo -u postgres pg_dump universal_links_production > $BACKUP_DIR/pre_deploy_$DATE.sql

# Pull latest changes
echo "⬇️ Pulling latest changes..."
cd $APP_DIR
git pull origin main

# Install/update dependencies
echo "📚 Installing dependencies..."
bundle install --deployment --without development test

# Run database migrations
echo "🗄️ Running database migrations..."
RAILS_ENV=production rails db:migrate

# Precompile assets
echo "🎨 Precompiling assets..."
RAILS_ENV=production rails assets:precompile

# Restart application
echo "🔄 Restarting application..."
sudo systemctl restart universal-links.service

# Wait for service to start
sleep 5

# Check service status
if sudo systemctl is-active --quiet universal-links.service; then
    echo "✅ Deployment successful!"
    echo "🌐 Application is running at: https://utilsawesome.com"
else
    echo "❌ Deployment failed! Check logs:"
    sudo journalctl -u universal-links.service --no-pager --lines=10
    exit 1
fi

echo "🎉 Deployment completed: $DATE"
```

```bash
# Make executable
sudo chmod +x /root/deploy-universal-links.sh

# Run deployment
sudo /root/deploy-universal-links.sh
```

## 🔧 Troubleshooting

### **Common Issues**

#### **Service Won't Start**
```bash
# Check service status
sudo systemctl status universal-links.service

# Check logs
sudo journalctl -u universal-links.service --no-pager --lines=20

# Common fixes
# 1. Check environment file exists
ls -la /root/universal_links/.env.production

# 2. Check database connection
RAILS_ENV=production rails db:migrate:status

# 3. Check file permissions
sudo chown -R root:root /root/universal_links
```

#### **Nginx 502 Bad Gateway**
```bash
# Check if Rails is running
sudo netstat -tlnp | grep :3000

# Check nginx error logs
sudo tail -f /var/log/nginx/universal_links_error.log

# Restart both services
sudo systemctl restart universal-links.service
sudo systemctl restart nginx
```

#### **SSL Certificate Issues**
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Test SSL configuration
curl -I https://utilsawesome.com
```

#### **Database Connection Issues**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Test database connection
sudo -u postgres psql universal_links_production -c "SELECT 1;"

# Check database permissions
sudo -u postgres psql -c "\du"
```

### **Performance Tuning**

#### **PostgreSQL Optimization**
```sql
-- Edit /etc/postgresql/12/main/postgresql.conf
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
```

#### **Rails Performance**
```bash
# Increase worker processes
# In .env.production:
WEB_CONCURRENCY=4
MAX_THREADS=5

# Enable caching
RAILS_ENV=production rails runner "Rails.cache.clear"
```

## 📈 Scaling Considerations

### **Horizontal Scaling**
- **Load Balancer**: Nginx or HAProxy for multiple app servers
- **Database**: PostgreSQL read replicas for read-heavy workloads
- **Session Store**: Redis for shared sessions across servers
- **File Storage**: S3 or CDN for static assets

### **Vertical Scaling**
- **CPU**: Scale up for concurrent users
- **Memory**: Scale up for large datasets and caching
- **Storage**: SSD for database performance
- **Network**: Higher bandwidth for traffic spikes

### **Monitoring Recommendations**
- **Application Monitoring**: New Relic, DataDog, or Skylight
- **Infrastructure Monitoring**: Prometheus + Grafana
- **Log Aggregation**: ELK Stack or Splunk
- **Uptime Monitoring**: Pingdom or UptimeRobot

---

This deployment guide provides comprehensive instructions for deploying Universal Links in production environments with proper security, monitoring, and backup procedures. 