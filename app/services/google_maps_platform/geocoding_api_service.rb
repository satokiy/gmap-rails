require 'net/http'
require 'json'

class GoogleMapsPlatform::GeocodingApiService
  include GoogleMapsPlatform::HttpClientBase

  attr_accessor :logger

  def initialize(address)

    # @logger = Logger.new(logger_path)
    # @logger.formatter = GoogleMapsPlatformLoggerFormatter.new

    @key = ENV["GMAP_API_KEY"]
    @address = address
  end

  def http_method
    'GET'
  end

  # def logger_path
  #   "log/maps_#{`hostname`.chop}_geocoding.log"
  # end

  def url
    "#{Settings.geocoding.url}#{@address}&key=#{@key}"
  end

  def encoded_url
    URI.encode(url)
  end

  def call
    uri = URI.parse(encoded_url)
    begin

    response = Net::HTTP.get_response(uri)
    case response
    when Net::HTTPSuccess then
      # 200 OK
      result = JSON.parse(response.body)
    else
      puts [uri.to_s, response.value].join(" : ")
    end

    rescue => e
      puts [uri.to_s, e.class, e].join(" : ")
    end
    result
  end

end


