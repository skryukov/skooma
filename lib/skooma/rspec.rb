# frozen_string_literal: true

require "yaml"

module Skooma
  # RSpec matchers for OpenAPI schema validation
  # @example
  #   require "skooma/rspec"
  #   # ...
  #   RSpec.configure do |config|
  #     # ...
  #     config.include Skooma::RSpec[Rails.root.join("docs", "openapi.yml")], type: :request
  #   end
  class RSpec < Module
    class << self
      alias_method :[], :new
    end

    module Mapper
      PLAIN_HEADERS = %w[CONTENT_LENGTH CONTENT_TYPE].freeze
      REGEXP_HTTP = /^HTTP_/.freeze

      def mapped_response(response: true, request: true)
        result = {
          "method" => env["REQUEST_METHOD"].downcase,
          "path" => env["PATH_INFO"]
        }

        if response
          result["response"] = {
            "status" => response_data[0],
            "headers" => response_data[1],
            "body" => response_data[2]
          }
        end

        if request
          result["request"] = {
            "query" => env["rack.request.query_string"] || env["QUERY_STRING"],
            "headers" => env.select { |k, _| k.start_with?("HTTP_") || PLAIN_HEADERS.include?(k) }.transform_keys { |k| k.sub(REGEXP_HTTP, "").split("_").map(&:capitalize).join("-") },
            "body" => env["RAW_POST_DATA"]
          }
        end

        result
      end

      def env
        request.env
      end

      def response_data
        [response.status, response.headers.to_h, response.body]
      end
    end

    def initialize(openapi_path, base_uri: "https://skoomarb.dev/")
      super()

      pathname = Pathname.new(openapi_path)

      registry = Skooma.create_registry
      registry.add_source(
        base_uri,
        JSONSkooma::Sources::Local.new(pathname.dirname.to_s)
      )
      schema = registry.schema(URI.parse("#{base_uri}#{pathname.basename}"), schema_class: Skooma::Objects::OpenAPI)

      include Mapper

      define_method :skooma_openapi_schema do
        schema
      end
    end
  end

  ::RSpec::Matchers.define(:conform_schema) do |expected_status|
    match do
      next false unless response.status == expected_status

      @result = skooma_openapi_schema.evaluate(mapped_response)
      @result.valid?
    end

    description do
      "conform schema with #{expected_status} response code"
    end

    failure_message do
      <<~MSG
        ENV:
        #{PP.pp(mapped_response, +"")}
        
        Validation Result:
        #{@result ? PP.pp(@result.output(:skooma), +"") : "Expected #{expected_status} status code"}
      MSG
    end
  end

  ::RSpec::Matchers.define(:conform_request_schema) do
    match do
      @result = skooma_openapi_schema.evaluate(mapped_response(response: false))
      @result.valid?
    end

    description do
      "conform request schema"
    end

    failure_message do
      <<~MSG
        ENV:
        #{PP.pp(mapped_response, +"")}
        
        Validation Result:
        #{@result ? PP.pp(@result.output(:skooma), +"") : "Expected #{expected_status} status code"}
      MSG
    end
  end

  ::RSpec::Matchers.define(:conform_response_schema) do |expected_status|
    match do
      next false unless response.status == expected_status

      @result = skooma_openapi_schema.evaluate(mapped_response(request: false))
      @result.valid?
    end

    description do
      "conform response schema with #{expected_status} response code"
    end

    failure_message do
      <<~MSG
        ENV:
        #{PP.pp(mapped_response, +"")}
        
        Validation Result:
        #{@result ? PP.pp(@result.output(:skooma), +"") : "Expected #{expected_status} status code"}
      MSG
    end
  end

  ::RSpec::Matchers.define(:be_valid_document) do
    match do |actual|
      @actual = actual
      next false unless comparable?

      @result = actual.validate
      @result.valid?
    end

    description { "be a valid OpenAPI document" }

    failure_message do
      next "expected value to be an OpenAPI object" unless comparable?

      pretty_output = PP.pp(@result.output(:detailed), +"")
      "must valid against OpenAPI specification:\n#{pretty_output}"
    end

    def comparable?
      actual.is_a?(Skooma::Objects::OpenAPI)
    end
  end
end
