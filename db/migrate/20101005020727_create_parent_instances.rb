class CreateParentInstances < ActiveRecord::Migration
  def self.up
    create_table :parent_instances do |t|
      t.integer :parent_chain_instance_id
      t.integer :child_chain_instance_id

      t.timestamps
    end
  end

  def self.down
    drop_table :parent_instances
  end
end
