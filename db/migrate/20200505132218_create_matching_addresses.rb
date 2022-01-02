class CreateMatchingAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :matching_addresses do |t|
      t.references :searched_address
      t.references :formatted_address

      t.timestamps
    end
  end
end
