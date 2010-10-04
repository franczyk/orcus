class Host < ActiveRecord::Base
  has_many :host_poolmaps
  has_many :pools, :through => :host_poolmaps
end
