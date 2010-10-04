class Action < ActiveRecord::Base
  has_many :chains
  belongs_to :pool
end
