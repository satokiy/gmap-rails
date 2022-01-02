class MatchingAddress < ApplicationRecord

  belongs_to :searched_address
  belongs_to :formatted_address

  validates_presence_of :formatted_address_id, :searched_address_id

end
