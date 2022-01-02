class CreateSearchedAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :searched_addresses do |t|
      t.string :address

      t.timestamps
    end
  end
end
