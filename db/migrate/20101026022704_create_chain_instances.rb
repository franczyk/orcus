class CreateChainInstances < ActiveRecord::Migration
  def self.up
    create_table :chain_instances do |t|
      t.integer :chain_id
      t.boolean :status
      t.datetime :completedtime
      t.datetime :starttime
      t.integer :timeout

      t.timestamps
    end
  end

  def self.down
    drop_table :chain_instances
  end
end
