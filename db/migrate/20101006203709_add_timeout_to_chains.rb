class AddTimeoutToChains < ActiveRecord::Migration
  def self.up
    add_column :chains, :timeout, :integer
  end

  def self.down
    remove_column :chains, :timeout
  end
end
