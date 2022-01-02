class FormattedAddress < ApplicationRecord

has_many :matching_addresses
has_many :searched_addresses, through: :matching_addresses

validates_presence_of  :address

end
