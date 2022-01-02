class ApplicationController < ActionController::Base
  before_action :basic if Rails.env == 'production'

  private

  def basic

    authenticate_or_request_with_http_basic do |name, password|
      name == 'gmap' && password == 'geocode0504'

    end

  end

end
