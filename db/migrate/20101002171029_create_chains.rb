class CreateChains < ActiveRecord::Migration
  def self.up
    create_table :chains do |t|
      t.integer :action_id
      t.string :precondition
      t.integer :retries

      t.timestamps
    end
  end

  def self.down
    drop_table :chains
  end
end
