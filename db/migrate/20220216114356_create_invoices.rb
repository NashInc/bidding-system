class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.bigint :auction_id
      t.bigint :customer_id
      t.string :invoice_id
      t.string :invoice_number
      t.decimal :amount
      t.string :bid_amount
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
