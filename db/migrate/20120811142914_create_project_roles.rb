class CreateProjectRoles < ActiveRecord::Migration
  def change
    create_table :project_roles do |t|
      t.string :name
      t.references :project, :null => false
      t.text :abilities
    end
    add_index :project_roles, :project_id
  end
end
