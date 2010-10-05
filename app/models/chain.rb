class Chain < ActiveRecord::Base
  has_many :automations
  belongs_to :action
  has_many :parent_child_relationships, :foreign_key => "child_chain_id", :class_name => "Parent"
  has_many :parents, :through => :parent_child_relationships, :source => :child

  has_many :child_parent_relationships, :foreign_key => "parent_chain_id", :class_name => "Parent"
  has_many :children, :through => :child_parent_relationships, :source => :parent
end