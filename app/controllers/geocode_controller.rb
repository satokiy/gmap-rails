class GeocodeController < ApplicationController

  def top

  end

  def index

  end

  def search
    @address = params[:address]
    google_map_search(@address)
    render("geocode/top")
  end

  def import
    @import_file = params[:file]
    redirect_to '/geocode' and return unless @import_file
    # csvの読み込みと出力を同時に行う
    csv_data = CSV.generate(headers: true) do |csv|
      csv << csv_attributes

      CSV.foreach(@import_file.path, headers: true) do |row|
        @address = row[0]
        results = google_map_search(@address)
        if results && ['OK', 'already_searched'].include?(results['status'])
          results['results'].each do |result|
            result_data = [
                @address,
                results['status'],
                result['formatted_address'],
                result['types'],
                result['geometry']['location_type']
            ]
            result_data << row[1].presence #請求ID
            result_data << row[2].presence #未着フラグ
            csv << result_data

          end
        else
          result_data = [
              @address,
              results
          ]
          csv << result_data
        end

      end
    end

    # csv出力
    send_data(csv_data, filename: "gmap_result_#{Time.now.strftime("%F")}.csv")

  end

  def s3_upload
    @csv_file = params[:file]
    redirect_to '/geocode' and return unless @csv_file
    s3 = Aws::S3::Resource.new(client: s3_client)
    bucket = s3.bucket(Settings.s3.bucket_name)
    object = bucket.object("uploads/#{@csv_file.original_filename}")
    object.put(body: @csv_file, acl: 'public-read')

    # render("geocode/top")
    redirect_to('/geocode/download')
  end

  # def csv_download
  #   file_name = params[:file]
  #   s3 = Aws::S3::Resource.new(client: s3_client)
  #   object = s3.bucket(Settings.s3.bucket_name).object("uploads/#{file_name}.csv")
  #   if object.present?
  #     send_data object.get.body.read,
  #               filename: "#{file_name}.csv"
  #   else
  #     # ファイルが無いときの処理
  #   end
  #
  # end

  def download
    s3 = Aws::S3::Resource.new(client: s3_client)
    @objects = s3.bucket(Settings.s3.bucket_name).objects(prefix: "processed/")
  end

  # def s3_download
  #     send_data 'hogehoge',
  #               :type => 'text/csv',
  #               :disposition => 'attachment'
  # end
  private

  def csv_attributes
    ["searched_address", "results", "formatted_address", "types", "location_type", "btm_id", "deliverable"]
  end

  def google_map_search(address)
    ActiveRecord::Base.transaction do
      searched_address = SearchedAddress.find_or_initialize_by(address: @address)

      # 検索が初めての住所の場合 -> APIコール
      # すでに検索済の場合 -> 既存の結果を返す
      if searched_address.new_record?
        searched_address.save!

        # API call
        @results = GoogleMapsPlatform::GeocodingApiService.new(@address).call

        #APIのリザルトを処理
        @results['results'].each do |result|

          # save result
          searched_address_response = SearchedAddressResponse.new(
              response: result,
              searched_address: searched_address
          )
          save_with_status(@results['status'], searched_address_response)

          # find_matching_address
          matching_address = FormattedAddress.find_by(address: result['formatted_address'])
          if matching_address
            MatchingAddress.create!(
                searched_address: searched_address,
                formatted_address: matching_address
            )
          else
            formatted_address = FormattedAddress.create!(
                address: result['formatted_address'],
            )
            MatchingAddress.create!(
                searched_address: searched_address,
                formatted_address: formatted_address
            )

          end
        end
      else
        searched_address_responses = SearchedAddressResponse.where(searched_address: searched_address)

        @results = {}
        @results['status'] = 'already_searched'
        @results['results'] = []
        searched_address_responses.each do |response|
          result = eval("#{response.response}")
          @results['results'] << result
        end
      end
    end
    @results
  end

  def save_with_status(status, searched_address_response)
    case status
    when 'OK'
      searched_address_response.ok!
    when 'ZERO_RESULTS'
      searched_address_response.zero_results!
    when 'OVER_DAILY_LIMIT'
      searched_address_response.over_daily_limit!
    when 'OVER_QUERY_LIMIT'
      searched_address_response.over_query_limit!
    when 'REQUEST_DENIED'
      searched_address_response.request_denied!
    when 'INVALID_REQUEST'
      searched_address_response.invalid_request!
    when 'UNKNOWN_ERROR'
      searched_address_response.unknown_error!
    end

    searched_address_response.save!
  end

  def s3_client
    Aws::S3::Client.new(
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_KEY_ID'],
        region: 'ap-northeast-1'
    )
  end

end

