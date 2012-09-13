class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable
  # :lockable, :timeoutable and :omniauthable
  # -- , :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :authentication_keys => [:login],
         :reset_password_keys => [:login],
         :confirmation_keys => [:login]

  validates_format_of :username, :with => /\A[a-z0-9_\-]+\Z/
  validate :validate_deleted_no_projects

  has_and_belongs_to_many :todo_items
  has_and_belongs_to_many :project_roles
  has_many :projects, :through => :project_roles, :uniq => true
  has_many :todo_lists, :through => :projects, :source => :lists
  has_many :all_todo_items, :through => :projects, :source => :items
  has_many :changes, :class_name => "TodoItemChanges"

  has_one :admin, :foreign_key => :email, :primary_key => :email

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :deleted_at,
     :locked, :feed_authentication_token, :confirmed_at
  attr_readonly :username

  # virtual attribute for :username + :email
  attr_accessor :login

  after_initialize :ensure_feed_authentication_token

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      login = login.downcase
      where(conditions).where(arel_table[:username].lower.eq(login).or(arel_table[:email].lower.eq(login))).first
    else
      where(conditions).first
    end
  end

  def self.search(login)
    login = "%#{login}%"
    where(arel_table[:username].lower.matches(login).or(arel_table[:email].lower.matches(login)))
  end

  def validate_deleted_no_projects
    if deleted_at and projects.count > 0
      errors[:base] << "Cannot delete account while it is member of projects"
    end
  end

  def active_for_authentication?
    super and !locked and deleted_at.nil?
  end

  def ensure_feed_authentication_token
    return self.feed_authentication_token unless self.feed_authentication_token.blank?
    self.feed_authentication_token = loop do
      token = Devise.friendly_token
      break token unless User.where(:feed_authentication_token => token).first
    end
  end

  def reset_feed_authentication_token
    self.feed_authentication_token = loop do
      token = Devise.friendly_token
      break token unless User.where(:feed_authentication_token => token).first
    end
  end

  def reset_feed_authentication_token!
    reset_feed_authentication_token
    save!
  end
end
