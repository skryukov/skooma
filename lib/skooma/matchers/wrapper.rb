# frozen_string_literal: true

require "pathname"

module Skooma
  module Matchers
    class Wrapper < Module
      TEST_REGISTRY_NAME = "skooma_test_registry"

      class << self
        alias_method :[], :new
      end

      module DefaultHelperMethods
        def mapped_response(with_response: true, with_request: true)
          Skooma::EnvMapper.call(
            request_object.env,
            response_object,
            with_response: with_response,
            with_request: with_request
          )
        end

        def request_object
          # `rails` integration
          return @request if defined?(::ActionDispatch) && @request.is_a?(::ActionDispatch::Request)
          # `rack-test` integration
          return last_request if defined?(::Rack::Test) && defined?(:last_request)

          raise "Request object not found"
        end

        def response_object
          # `rails` integration
          return @response if defined?(::ActionDispatch) && @response.is_a?(::ActionDispatch::Response)
          # `rack-test` integration
          return last_response if defined?(::Rack::Test) && defined?(:last_response)

          raise "Response object not found"
        end

        def skooma_openapi_schema
          skooma.schema
        end
      end

      def initialize(helper_methods_module, openapi_path, base_uri: "https://skoomarb.dev/", path_prefix: "", enforce_access_modes: false, use_patterns_for_path_matching: false, **params)
        super()

        registry = create_test_registry
        pathname = Pathname.new(openapi_path)
        source_uri = "#{base_uri}#{path_prefix.delete_suffix("/").delete_prefix("/")}"
        source_uri += "/" unless source_uri.end_with?("/")
        registry.add_source(
          source_uri,
          JSONSkooma::Sources::Local.new(pathname.dirname.to_s)
        )
        @schema = registry.schema(URI.parse("#{source_uri}#{pathname.basename}"), schema_class: Skooma::Objects::OpenAPI)
        @schema.path_prefix = path_prefix
        @schema.enforce_access_modes = enforce_access_modes

        @coverage = Coverage.new(@schema, mode: params[:coverage], format: params[:coverage_format])

        @schema.use_patterns_for_path_matching = use_patterns_for_path_matching

        include DefaultHelperMethods
        include helper_methods_module

        skooma_self = self
        define_method :skooma do
          skooma_self
        end
      end

      attr_accessor :schema, :coverage

      private

      def create_test_registry
        JSONSkooma::Registry[TEST_REGISTRY_NAME]
      rescue JSONSkooma::RegistryError
        Skooma.create_registry(name: TEST_REGISTRY_NAME)
      end
    end
  end
end
