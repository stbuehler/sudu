class CreateTodoLists < ActiveRecord::Migration
  def change
    create_table :todo_lists do |t|
      t.references :project, :null => false
      t.string :name

      t.timestamps
    end
    add_index :todo_lists, :project_id
  end
end
