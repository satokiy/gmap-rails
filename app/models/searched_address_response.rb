class SearchedAddressResponse < ApplicationRecord

  belongs_to :searched_address
  enum status: {
    ok: 0,
    zero_results: 1,
    over_daily_limit: 2,
    over_query_limit: 3,
    request_denied: 4,
    invalid_request: 5,
    unknown_error: 6
}
  validates_presence_of :searched_address_id

end
