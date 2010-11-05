# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101102033323) do

  create_table "acts", :force => true do |t|
    t.string   "description"
    t.string   "command"
    t.integer  "pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "automations", :force => true do |t|
    t.integer  "chain_id"
    t.boolean  "active"
    t.string   "precondition"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chain_instances", :force => true do |t|
    t.integer  "chain_id"
    t.boolean  "status"
    t.datetime "completedtime"
    t.boolean  "completed"
    t.datetime "starttime"
    t.integer  "timeout"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chains", :force => true do |t|
    t.integer  "act_id"
    t.string   "precondition"
    t.integer  "retries"
    t.integer  "timeout"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "chain_id"
    t.integer  "act_id"
    t.datetime "date"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "host_poolmaps", :force => true do |t|
    t.integer  "pool_id"
    t.integer  "host_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", :force => true do |t|
    t.string   "name"
    t.datetime "last_checkin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parent_instances", :force => true do |t|
    t.integer  "parent_chain_instance_id"
    t.integer  "child_chain_instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parents", :force => true do |t|
    t.integer  "parent_chain_id"
    t.integer  "child_chain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pools", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
