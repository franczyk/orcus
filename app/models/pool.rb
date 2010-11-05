class Pool < ActiveRecord::Base
  has_many :host_poolmaps
  has_many :hosts, :through => :host_poolmaps
  has_many :acts
end
