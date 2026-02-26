# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_26_015948) do
  create_table "assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "employee_id", null: false
    t.date "end_date"
    t.date "start_date"
    t.integer "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_assignments_on_employee_id"
    t.index ["store_id"], name: "index_assignments_on_store_id"
  end

  create_table "employees", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.integer "role", default: 1
    t.string "ssn"
    t.datetime "updated_at", null: false
  end

  create_table "stores", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "city"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "phone"
    t.string "state"
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zip"
  end

  add_foreign_key "assignments", "employees"
  add_foreign_key "assignments", "stores"
end
