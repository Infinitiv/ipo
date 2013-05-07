class Question < ActiveRecord::Base
  belongs_to :subject
  has_many :answers, :dependent => :destroy
end
