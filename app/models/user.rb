class User < ActiveRecord::Base
  validates :login, :presence => true, 
            :length => { :maximum => 50 }, 
            :uniqueness => true
  validates :password, :confirmation => true,
	    :presence => true
  validates :password_confirmation, :presence => true
  has_secure_password
end
