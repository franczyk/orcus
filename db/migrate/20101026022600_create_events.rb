class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :chain_id
      t.integer :action_id
      t.datetime :date
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
