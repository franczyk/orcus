class CreateActionargs < ActiveRecord::Migration
  def self.up
    create_table :actionargs do |t|
      t.integer :action_id
      t.string :argname
      t.string :argvalue

      t.timestamps
    end
  end

  def self.down
    drop_table :actionargs
  end
end
