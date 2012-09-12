class CreateTodoItemChanges < ActiveRecord::Migration
  def change
    create_table :todo_item_changes do |t|
      t.references :todo_item, :null => false
      t.references :user, :null => false
      t.text :status
      t.text :comment
      t.text :description

      t.timestamps
    end
    add_index :todo_item_changes, :todo_item_id
    add_index :todo_item_changes, :user_id
  end
end
