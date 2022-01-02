module GoogleMapsPlatform::HttpClientBase

# Bodyをhashに変換できなかった場合にスローするエクセプション
  class BodyParseError < StandardError
  end
  # API通信時のエラー
  class ApiCallError < StandardError
  end
  # APIと通信した結果、先方からエラーコードが返却された場合のエラー
  class ApiInvalidRequestError < StandardError
  end

  class GoogleMapsPlatformLoggerFormatter < ::Logger::Formatter
    FORMAT          = "[%s] %s\n".freeze
    DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%S.%6N'.freeze

    def initialize
      @datetime_format = DATETIME_FORMAT
    end

    def call(_severity, time, _progname, msg)
      format(FORMAT, format_datetime(time), msg2str(msg))
    end
  end

  def build_request
    http_params = Net::HTTP::Get.new(url.path)
    http_params['Content-Type'] = 'application/json'

    http_params
  end

  def logging_request(http_params)
    # リクエストヘッダのロギング
    logger.info("REQUEST")
    logger.info("URL: #{url}")
    http_params.each_capitalized { |k, v| logger.info("#{k}: #{v}") }
  end

  def logging_response(res)

    logger.info("RESPONSE")
    logger.info("HTTP_STATUS: #{res.code}")
    res.each_capitalized do |k, v|
      logger.info("#{k}: #{v}")
    end
    logger.info("BODY: #{res.body}")
  end
# Httpレスポンスを拡張するclass
  class WrapResponse

    attr_accessor :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    # 元の生データ
    def raw_body
      @raw_body ||= @http_response.body
    end

    # HTTPステータスを取得
    def http_status_code
      @http_status_code ||= @http_response.code
    end

    def body
      # TrustDockにDeleteリクエストを送ると成功になる場合、nilパラメーターを貰う
      if raw_body.present?
        # Hash化
        body = JSON.parse(raw_body)
        body.with_indifferent_access
      end
    rescue => e
      # エラーを補足したい場合はBodyParseErrorをwatchする
      raise BodyParseError.new e
    end

    alias hash body
  end
end
