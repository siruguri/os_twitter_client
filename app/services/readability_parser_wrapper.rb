class ReadabilityParserWrapper
  class ReadabilityBody
    attr_reader :content, :url
    def initialize(content:, url:)
      @content = content
      @url = url
    end
  end
  
  def initialize
    @_key = Rails.application.secrets.readability_api_key
  end

  def parse(uri_string)
    uri_string.chomp!
    uri = URI "https://www.readability.com/api/content/v1/parser?format=json&token=#{@_key}&url=#{CGI.escape(uri_string)}"

    response = ''
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      # Free API is 1000 a day
      sleep 80 unless Rails.env.test?
    end
    
    encoding = response.header['Content-Type']
    readability_data = JSON.parse(response.body)

    body =
      case encoding
      when /iso.8859.1/i
        readability_data['content'].force_encoding(Encoding::ISO_8859_1)
      when /utf\-8/i
        readability_data['content'].force_encoding(Encoding::UTF_8)
      when /text.plain/i
        # This is probably when readability threw an error, in which case the hash will have a key called failure_message
        response.body
      else
        raise Exception.new("Cannot understand content type #{response.header['Content-Type']}")
      end

    ReadabilityBody.new(content: body, url: readability_data['url'])
  end
end
