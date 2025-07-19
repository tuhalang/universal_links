class AddUserToDynamicLinks < ActiveRecord::Migration[8.0]
  def change
    add_reference :dynamic_links, :user, null: true, foreign_key: true, index: true
  end
end
