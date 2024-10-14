# frozen_string_literal: true

require "minitest/unit"

module Skooma
  # Minitest helpers for OpenAPI schema validation
  # @example
  #   describe TestApp do
  #     include Skooma::Minitest[Rails.root.join("docs", "openapi.yml")]
  #     # ...
  #   end
  class Minitest < Matchers::Wrapper
    module HelperMethods
      def assert_conform_schema(expected_status)
        matcher = Matchers::ConformSchema.new(skooma, mapped_response, expected_status)

        assert matcher.matches?, -> { matcher.failure_message }
      end

      def assert_conform_request_schema
        matcher = Matchers::ConformRequestSchema.new(skooma, mapped_response(with_response: false))

        assert matcher.matches?, -> { matcher.failure_message }
      end

      def assert_conform_response_schema(expected_status)
        matcher = Matchers::ConformResponseSchema.new(skooma, mapped_response(with_request: false), expected_status)

        assert matcher.matches?, -> { matcher.failure_message }
      end

      def assert_is_valid_document(document)
        matcher = Matchers::BeValidDocument.new

        assert matcher.matches?(document), -> { matcher.failure_message }
      end
    end

    def initialize(openapi_path, **params)
      super(HelperMethods, openapi_path, **params)

      ::Minitest.after_run { coverage.report }
    end
  end
end
