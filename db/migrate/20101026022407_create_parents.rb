class CreateParents < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
      t.integer :parent_chain_id
      t.integer :child_chain_id

      t.timestamps
    end
  end

  def self.down
    drop_table :parents
  end
end
