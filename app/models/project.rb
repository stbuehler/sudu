class Project < ActiveRecord::Base
  attr_accessible :name

  has_many :roles, :class_name => "ProjectRole", :dependent => :destroy
  has_many :users, :through => :roles, :uniq => true
  
  has_many :lists, :class_name => "TodoList", :dependent => :destroy
  has_many :items, :through => :lists
  
  validates_presence_of :name
  
  def last_managing_role
    managing_roles.count == 1
  end
  
  def managing_roles
    roles.where(["abilities LIKE :a", {:a => '%:manage:%'}])
  end
  
  def last_managing_user
    managing_users.count == 1
  end
  
  def managing_users
    User.joins(:project_roles).where(["project_roles.abilities LIKE ? AND project_roles.project_id = ?", '%:manage:%', id]).uniq
  end  
end
