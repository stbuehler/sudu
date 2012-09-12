class CreateProjectRolesUsers < ActiveRecord::Migration
  def change
    create_table :project_roles_users, :id => false do |t|
      t.references :project_role, :null => false
      t.references :user, :null => false
    end
    add_index :project_roles_users, :user_id
    add_index :project_roles_users, :project_role_id
    add_index :project_roles_users, [:project_role_id,:user_id], :unique => true
  end
end
