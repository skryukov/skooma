# frozen_string_literal: true

module Skooma
  module EnvMapper
    class << self
      PLAIN_HEADERS = %w[CONTENT_LENGTH CONTENT_TYPE].freeze
      REGEXP_HTTP = /^HTTP_/.freeze

      def call(env, response = nil, with_response: true, with_request: true)
        result = {
          "method" => env["REQUEST_METHOD"].downcase,
          "path" => env["action_dispatch.original_path"] || env["PATH_INFO"]
        }
        result["request"] = map_request(env) if with_request
        result["response"] = map_response(response) if response && with_response

        result
      end

      private

      def map_request(env)
        {
          "query" => env["rack.request.query_string"] || env["QUERY_STRING"],
          "headers" => env.select { |k, _| k.start_with?("HTTP_") || PLAIN_HEADERS.include?(k) }.transform_keys { |k| k.sub(REGEXP_HTTP, "").split("_").map(&:capitalize).join("-") },
          "body" => env["RAW_POST_DATA"]
        }
      end

      def map_response(response)
        status, headers, body = response.to_a
        full_body = +""
        body.each { |chunk| full_body << chunk }
        {
          "status" => status,
          "headers" => headers.to_h,
          "body" => full_body
        }
      end
    end
  end
end
