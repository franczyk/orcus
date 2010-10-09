class ParentInstance < ActiveRecord::Base
  belongs_to :parent, :class_name => 'ChainInstance', :foreign_key => 'parent_chain_instance_id'
  belongs_to :child, :class_name => 'ChainInstance', :foreign_key => 'child_chain_instance_id'
  #validates_existence_of :parent, :child

end
