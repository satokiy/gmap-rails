class CreateSearchedAddressResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :searched_address_responses do |t|
      t.string :response
      t.references :searched_address
      t.integer :status

      t.timestamps
    end
  end
end
