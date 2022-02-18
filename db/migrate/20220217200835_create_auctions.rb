class CreateAuctions < ActiveRecord::Migration[7.0]
  def change
    create_table :auctions do |t|
      t.datetime :start
      t.datetime :end
      t.decimal :target
      t.string :item_id
      t.string :item_name
      t.string :customer_id

      t.timestamps
    end
  end
end
