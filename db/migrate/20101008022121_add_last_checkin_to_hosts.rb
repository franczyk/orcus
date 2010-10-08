class AddLastCheckinToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :last_checkin, :datetime
  end

  def self.down
    remove_column :hosts, :last_checkin
  end
end
