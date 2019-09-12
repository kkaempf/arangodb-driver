module Arango
  class Request
    def initialize(return_output:, base_uri:, options:, verbose:, async:)
      @return_output = return_output
      @base_uri = base_uri
      @options = options
      @verbose = verbose
      @async = async
    end

    attr_accessor :async, :base_uri, :options, :return_output, :verbose

    def request(action, url, body: {}, headers: {}, query: {}, key: nil, skip_to_json: false, keep_null: false,
                skip_parsing: false)
      send_url = "#{@base_uri}/"
      send_url += url

      if body.is_a?(Hash)
        body.delete_if{|_,v| v.nil?} unless keep_null
      end
      query.delete_if{|_,v| v.nil?}
      headers.delete_if{|_,v| v.nil?}
      options = @options.merge({ body: body, params: query })
      options[:headers].merge!(headers)

      if %w[GET HEAD DELETE].include?(action)
        options.delete(:body)
      end

      if @verbose
        puts "\n===REQUEST==="
        puts "#{action} #{send_url}\n"
        puts JSON.pretty_generate(options)
        puts "==============="
      end

      if !skip_to_json && !options[:body].nil?
        options[:body] = Oj.dump(options[:body], mode: :json)
      end
      options.delete_if{|_,v| v.empty?}

      begin
        response = case action
        when "GET"
          Typhoeus.get(send_url, options)
        when "HEAD"
          Typhoeus.head(send_url, options)
        when "PATCH"
          Typhoeus.patch(send_url, options)
        when "POST"
          Typhoeus.post(send_url, options)
        when "PUT"
          Typhoeus.put(send_url, options)
        when "DELETE"
          Typhoeus.delete(send_url, options)
        end
      rescue Exception => e
        raise Arango::Error.new err: :impossible_to_connect_with_database,
          data: {error: e.message}
      end

      if @verbose
        puts "\n===RESPONSE==="
        puts "CODE: #{response.code}"
      end

      case @async
      when :store
        val = response.headers["x-arango-async-id"]
        if @verbose
          puts val
          puts "==============="
        end
        return val
      when true
        puts "===============" if @verbose
        return true
      end

      if skip_parsing
        val = response.response_body
        if @verbose
          puts val
          puts "==============="
        end
        return val
      end

      begin
        json_result = unless response.response_body.empty?
                   Oj.load(response.response_body, mode: :json, symbol_keys: true)
                 else
                   {}
                 end
        result = Arango::Result.new(json_result)
      rescue Exception => e
        raise Arango::Error.new err: :impossible_to_parse_arangodb_response,
          data: { response: response.response_body, action: action, url: send_url, request: JSON.pretty_generate(options) }
      end

      if @verbose
        puts JSON.pretty_generate(result.to_h)
        puts "==============="
      end

      if !result.is_array? && result[:error]
        raise Arango::ErrorDB.new(message: result[:errorMessage], code: result[:code], data: result, error_num: result[:errorNum],
                                  action: action, url: send_url, request: options)
      end
      key ? result[key] : result
    end

    def download(url:, path:, body: {}, headers: {}, query: {})
      send_url = "#{@base_uri}/"
      send_url += url
      body.delete_if{|_,v| v.nil?}
      query.delete_if{|_,v| v.nil?}
      headers.delete_if{|_,v| v.nil?}
      body = Oj.dump(body, mode: :json)
      options = @options.merge({body: body, query: query, headers: headers, stream_body: true})
      puts "\n#{action} #{send_url}\n" if @verbose
      File.open(path, "w") do |file|
        file.binmode
        Typhoeus.post(send_url, options) do |fragment|
          file.write(fragment)
        end
      end
    end
  end
end
