class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :customer_id
      t.string :phone_number
      t.string :email

      t.timestamps
    end
  end
end
