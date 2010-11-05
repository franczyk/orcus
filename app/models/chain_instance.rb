class ChainInstance < ActiveRecord::Base
  belongs_to :chain
  
  has_many :parent_child_relationships, :foreign_key => "child_chain_instance_id", :class_name => "ParentInstance"
  has_many :parents, :through => :parent_child_relationships, :source => :child

  has_many :child_parent_relationships, :foreign_key => "parent_chain_instance_id", :class_name => "ParentInstance"
  has_many :children, :through => :child_parent_relationships, :source => :parent
  
  has_many :output
  #validates_existence_of :chain
end
