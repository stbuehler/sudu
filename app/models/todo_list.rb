class TodoList < ActiveRecord::Base
  belongs_to :project
  attr_accessible :name
  
  has_many :items, :class_name => "TodoItem", :dependent => :destroy
  
  validates_presence_of :name
end
