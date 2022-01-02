class CreateFormattedAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :formatted_addresses do |t|
      t.string :address

      t.timestamps
    end
  end
end
