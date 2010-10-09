class AddCompletedToChainInstance < ActiveRecord::Migration
  def self.up
    add_column :chain_instances, :completed, :boolean
  end

  def self.down
    remove_column :chain_instances, :completed
  end
end
