# frozen_string_literal: true

module Skooma
  # RSpec matchers for OpenAPI schema validation
  # @example
  #   RSpec.configure do |config|
  #     # ...
  #     config.include Skooma::RSpec[Rails.root.join("docs", "openapi.yml")], type: :request
  #   end
  class RSpec < Matchers::Wrapper
    module HelperMethods
      def conform_schema(expected_status)
        Matchers::ConformSchema.new(skooma_openapi_schema, mapped_response, expected_status)
      end

      def conform_response_schema(expected_status)
        Matchers::ConformResponseSchema.new(skooma_openapi_schema, mapped_response(with_request: false), expected_status)
      end

      def conform_request_schema
        Matchers::ConformRequestSchema.new(skooma_openapi_schema, mapped_response(with_response: false))
      end

      def be_valid_document
        Matchers::BeValidDocument.new
      end
    end

    def initialize(openapi_path, **params)
      super(HelperMethods, openapi_path, **params)
    end
  end
end
