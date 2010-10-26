class CreateAutomations < ActiveRecord::Migration
  def self.up
    create_table :automations do |t|
      t.integer :chain_id
      t.boolean :active
      t.string :precondition

      t.timestamps
    end
  end

  def self.down
    drop_table :automations
  end
end
