class TodoItem < ActiveRecord::Base
  belongs_to :list, :class_name => "TodoList", :foreign_key => :todo_list_id
  attr_accessible :open, :title, :list, :users, :priority, :suspend_till
  
  has_one :project, :through => :list
  
  has_many :changes, :class_name => "TodoItemChanges", :dependent => :destroy
  has_one :last_change, :class_name => "TodoItemChanges", :order => "created_at DESC"
  has_one :last_description_change, :class_name => "TodoItemChanges", :order => "created_at DESC", :conditions => "description IS NOT NULL"
  
  has_and_belongs_to_many :users

  validates_presence_of :title

  LOW = 0
  NORMAL = 1
  HIGH = 2
  URGENT = 3
  PRIORITIES = [ :low, :normal, :high, :urgent ]
  validates :priority, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 4 } 

  after_initialize :init_default_priority

  class << self
    def active
      where(:open => true).where(arel_table[:suspend_till].eq(nil).or(arel_table[:suspend_till].gt(Date.current).not))
    end

    def priority_to_s(p)
      PRIORITIES[p].to_s.capitalize
    end

    def default_order
      order('priority DESC, id DESC')
    end
  end

  def active?
    open and (suspend_till.nil? or suspend_till <= Date.current)
  end

  def suspended?
    (!suspend_till.nil? and suspend_till > Date.current)
  end

  def priority_to_s
    TodoItem.priority_to_s(priority)
  end

  def description
    lastdescchange = last_description_change
    lastdescchange && lastdescchange.description
  end

private
  def init_default_priority
    self.priority ||= NORMAL
  end
end
