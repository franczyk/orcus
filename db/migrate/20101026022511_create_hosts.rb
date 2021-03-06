class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.string :name
      t.datetime :last_checkin

      t.timestamps
    end
  end

  def self.down
    drop_table :hosts
  end
end
