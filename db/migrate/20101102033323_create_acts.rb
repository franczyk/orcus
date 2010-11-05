class CreateActs < ActiveRecord::Migration
  def self.up
    create_table :acts do |t|
      t.string :description
      t.string :command
      t.integer :pool_id

      t.timestamps
    end
  end

  def self.down
    drop_table :acts
  end
end
