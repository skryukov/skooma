# frozen_string_literal: true

module Skooma
  # Minitest helpers for OpenAPI schema validation
  # @example
  #   describe TestApp do
  #     include Skooma::RSpec[Rails.root.join("docs", "openapi.yml")]
  #     # ...
  #   end
  class Minitest < Matchers::Wrapper
    module HelperMethods
      def assert_conform_schema(expected_status)
        matcher = Matchers::ConformSchema.new(skooma_openapi_schema, mapped_response, expected_status)

        assert matcher.matches?, -> { matcher.failure_message }
      end

      def assert_conform_request_schema
        matcher = Matchers::ConformRequestSchema.new(skooma_openapi_schema, mapped_response(with_response: false))

        assert matcher.matches?, -> { matcher.failure_message }
      end

      def assert_conform_response_schema(expected_status)
        matcher = Matchers::ConformResponseSchema.new(skooma_openapi_schema, mapped_response(with_request: false), expected_status)

        assert matcher.matches?, -> { matcher.failure_message }
      end

      def assert_is_valid_document(document)
        matcher = Matchers::BeValidDocument.new

        assert matcher.matches?(document), -> { matcher.failure_message }
      end
    end

    def initialize(openapi_path, **params)
      super(HelperMethods, openapi_path, **params)
    end
  end
end
