class Parent < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Chain', :foreign_key => 'parent_chain_id'
  belongs_to :child, :class_name => 'Chain', :foreign_key => 'child_chain_id'
  #validates_existence_of :parent_chain, :child_chain
end
