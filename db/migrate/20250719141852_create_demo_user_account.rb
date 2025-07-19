class CreateDemoUserAccount < ActiveRecord::Migration[8.0]
  def up
    # Find the admin user and convert to demo user
    admin_user = User.find_by(email: 'admin@utilsawesome.com')

    if admin_user
      admin_user.update!(
        name: 'Demo User',
        email: 'demo@utilsawesome.com',
        role: 'user'  # Change from admin to regular user
      )
      puts "✅ Converted admin user to demo user (demo@utilsawesome.com / admin123)"
      puts "   Role changed from 'admin' to 'user'"
    else
      # Create demo user if no admin exists
      demo_user = User.create!(
        name: 'Demo User',
        email: 'demo@utilsawesome.com',
        password: 'demo123',
        password_confirmation: 'demo123',
        role: 'user'
      )

      # Assign existing links to demo user
      DynamicLink.where(user_id: nil).update_all(user_id: demo_user.id)
      puts "✅ Created demo user (demo@utilsawesome.com / demo123)"
      puts "✅ Assigned #{DynamicLink.where(user_id: demo_user.id).count} existing links to demo user"
    end
  end

  def down
    # Convert back to admin if needed
    demo_user = User.find_by(email: 'demo@utilsawesome.com')

    if demo_user
      demo_user.update!(
        name: 'Admin User',
        email: 'admin@utilsawesome.com',
        role: 'admin'
      )
      puts "✅ Converted demo user back to admin user"
    end
  end
end
