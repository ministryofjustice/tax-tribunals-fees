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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161215103044) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "case_requests", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "case_reference",    null: false
    t.string   "confirmation_code", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "fees", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "case_reference"
    t.string   "case_title"
    t.string   "confirmation_code_digest"
    t.string   "description"
    t.integer  "amount"
    t.integer  "glimr_id"
    t.string   "govpay_payment_status"
    t.string   "govpay_payment_message"
    t.string   "govpay_reference"
    t.string   "govpay_payment_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "help_with_fees_reference"
    t.string   "pay_by_account_reference"
    t.string   "pay_by_account_confirmation"
    t.string   "pay_by_account_transaction_reference"
    t.uuid     "case_request_id"
    t.index ["case_reference"], name: "index_fees_on_case_reference", using: :btree
  end

end
