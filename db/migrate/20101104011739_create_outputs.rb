class CreateOutputs < ActiveRecord::Migration
  def self.up
    create_table :outputs do |t|
      t.integer :chain_instance_id
      t.string :output

      t.timestamps
    end
  end

  def self.down
    drop_table :outputs
  end
end
