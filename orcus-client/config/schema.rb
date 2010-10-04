require 'config/database_configuration'
class Action < ActiveRecord::Base
  has_many :chains
  belongs_to :pool
end
class Automation < ActiveRecord::Base
  belongs_to :chain
end
class Chain < ActiveRecord::Base
  has_many :automations
  belongs_to :action
  has_many :parent_child_relationships, :foreign_key => "child_chain_id", :class_name => "Parent"
  has_many :parents, :through => :parent_child_relationships, :source => :child

  has_many :child_parent_relationships, :foreign_key => "parent_chain_id", :class_name => "Parent"
  has_many :children, :through => :child_parent_relationships, :source => :parent
end
class Event < ActiveRecord::Base
end
class Host < ActiveRecord::Base
  has_many :host_poolmaps
  has_many :pools, :through => :host_poolmaps
end
class HostPoolmap < ActiveRecord::Base
  belongs_to :host
  belongs_to :pool
end
class Parent < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Chain', :foreign_key => 'parent_chain_id'
  belongs_to :child, :class_name => 'Chain', :foreign_key => 'child_chain_id'
  #validates_existence_of :parent_chain, :child_chain
end
class Pool < ActiveRecord::Base
  has_many :host_poolmaps
  has_many :hosts, :through => :host_poolmaps
  has_many :actions
end
