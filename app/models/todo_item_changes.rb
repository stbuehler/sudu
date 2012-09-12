class TodoItemChanges < ActiveRecord::Base
  belongs_to :item, :class_name => "TodoItem", :foreign_key => :todo_item_id
  belongs_to :user
  attr_accessible :comment, :description, :status, :user
  
  def status_append(*msg)
    return status if msg.empty?
    msg = msg.join('\n')
    write_attribute :status, status.to_s.empty? ? msg : status + "\n" + msg
  end
end
