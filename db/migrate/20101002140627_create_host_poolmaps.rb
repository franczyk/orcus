class CreateHostPoolmaps < ActiveRecord::Migration
  def self.up
    create_table :host_poolmaps do |t|
      t.integer :pool_id
      t.integer :host_id

      t.timestamps
    end
  end

  def self.down
    drop_table :host_poolmaps
  end
end
