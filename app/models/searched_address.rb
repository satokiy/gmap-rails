class SearchedAddress < ApplicationRecord

  has_many :searched_address_responses
  has_many :matching_addresses
  has_many :formatted_addresses, through: :matching_addresses

  validates_presence_of :address

end
