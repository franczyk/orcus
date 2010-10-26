require 'config/database_configuration'

class Action < ActiveRecord::Base
  belongs_to :chain
end
class Automation < ActiveRecord::Base
  belongs_to :chain
end
class Chain < ActiveRecord::Base
  has_many :automations
  belongs_to :action
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
  belongs_to :parent_chain, :class_name => 'Chain', :foreign_key => 'parent_chain_id'
  belongs_to :child_chain, :class_name => 'Chain', :foreign_key => 'child_chain_id'
  validates_presence_of :parent_chain, :child_chain
end
class Pool < ActiveRecord::Base
  has_many :host_poolmaps
  has_many :hosts, :through => :host_poolmaps
end
