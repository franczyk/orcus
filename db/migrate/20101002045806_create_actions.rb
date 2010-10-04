class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.string :description
      t.string :command
      t.integer :pool_id

      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
