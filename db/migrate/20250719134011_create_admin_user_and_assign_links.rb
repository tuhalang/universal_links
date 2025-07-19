class CreateAdminUserAndAssignLinks < ActiveRecord::Migration[8.0]
  def up
    # Create admin user if it doesn't exist
    admin_user = User.find_or_create_by(email: 'admin@utilsawesome.com') do |user|
      user.name = 'Admin User'
      user.password = 'admin123'
      user.password_confirmation = 'admin123'
      user.role = 'admin'
    end

    # Assign all existing dynamic links to the admin user
    DynamicLink.where(user_id: nil).update_all(user_id: admin_user.id)

    puts "✅ Created admin user (admin@utilsawesome.com / admin123)"
    puts "✅ Assigned #{DynamicLink.where(user_id: admin_user.id).count} existing links to admin"
  end

  def down
    # Remove the admin user and set links back to nil
    admin_user = User.find_by(email: 'admin@utilsawesome.com')
    if admin_user
      DynamicLink.where(user_id: admin_user.id).update_all(user_id: nil)
      admin_user.destroy
    end
  end
end
