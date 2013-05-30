class Subject < ActiveRecord::Base
  has_many :questions, :dependent => :destroy
  default_scope order('name')
end
