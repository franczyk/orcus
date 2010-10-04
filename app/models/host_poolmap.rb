class HostPoolmap < ActiveRecord::Base
  belongs_to :host
  belongs_to :pool
end
