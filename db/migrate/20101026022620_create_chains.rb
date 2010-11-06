class CreateChains < ActiveRecord::Migration
  def self.up
    create_table :chains do |t|
      t.integer :act_id
      t.integer :trigger_id
      t.string :precondition
      t.integer :retries
      t.integer :timeout

      t.timestamps
    end
  end

  def self.down
    drop_table :chains
  end
end
