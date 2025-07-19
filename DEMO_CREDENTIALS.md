# 🎯 Demo Account Credentials

## Login Information
- **URL**: http://localhost:3000/login
- **Email**: `demo@utilsawesome.com`
- **Password**: `admin123`
- **Role**: Regular User (not admin)

## Account Features

### ✅ Available Features
- Create and manage personal dynamic links
- View detailed analytics for your links
- Edit link configurations (iOS, Android, Web)
- Access all user-level dashboard features
- Real-time click tracking and statistics

### ❌ Restricted Features
- Cannot view other users' links (admin-only)
- Cannot access admin dashboard features
- Cannot manage other user accounts

## Getting Started

1. Visit http://localhost:3000
2. Click "🔑 Login" 
3. Use the credentials above
4. Start creating smart links!

## Reset Instructions

If you need to reset the demo account, run:
```bash
rails db:rollback STEP=1  # Rollback to admin
rails db:migrate          # Convert back to demo user
```

---
*This demo account is automatically created when you run `rails db:migrate`* 