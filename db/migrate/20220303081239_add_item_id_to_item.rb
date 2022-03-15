class AddItemIdToItem < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :item_id, :string
  end
end
