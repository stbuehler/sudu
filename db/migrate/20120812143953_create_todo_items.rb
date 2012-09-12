class CreateTodoItems < ActiveRecord::Migration
  def change
    create_table :todo_items do |t|
      t.references :todo_list, :null => false
      t.string :title, :null => false
      t.boolean :open, :null => false
      t.date :suspend_till
      t.integer :priority, :null => false

      t.timestamps
    end
    add_index :todo_items, :todo_list_id
    add_index :todo_items, :open
  end
end
