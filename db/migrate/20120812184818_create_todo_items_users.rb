class CreateTodoItemsUsers < ActiveRecord::Migration
  def change
    create_table :todo_items_users, :id => false do |t|
      t.references :todo_item, :null => false
      t.references :user, :null => false
    end
    add_index :todo_items_users, :todo_item_id
    add_index :todo_items_users, :user_id
    add_index :todo_items_users, [:todo_item_id,:user_id], :unique => true
  end
end
