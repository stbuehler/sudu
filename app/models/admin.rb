class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # -- :registerable, :rememberable, :trackable
  devise :database_authenticatable,
         :recoverable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password
  #, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  has_one :user, :foreign_key => :email, :primary_key => :email
end
