class TodoItemChanges < ActiveRecord::Base
  belongs_to :item, :class_name => "TodoItem", :foreign_key => :todo_item_id
  belongs_to :user
  has_one :project, :through => :item

  attr_accessible :comment, :description, :status, :user

  def current_description
    c = item.changes.where(TodoItemChanges::arel_table[:created_at].gt(created_at).not).where("description IS NOT NULL").order("created_at DESC").first
    c && c.description
  end

  def status_append(*msg)
    return status if msg.empty?
    msg = msg.join('\n')
    write_attribute :status, status.to_s.empty? ? msg : status + "\n" + msg
  end

  class << self
    def since(date)
      where(arel_table[:created_at].gt(date))
    end
  end
end
