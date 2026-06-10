# frozen_string_literal: true

require "pathname"
require "securerandom"

module ExternalRefsHelpers
  FIXTURES_DIR = File.expand_path("../openapi_test_suite/external_refs", __dir__)

  def load_external_refs_fixture(case_name)
    root_file = Dir["#{FIXTURES_DIR}/#{case_name}/openapi.{yaml,yml,json}"].first
    load_external_refs_openapi(File.dirname(root_file), filename: File.basename(root_file), tag: case_name)
  end

  def load_external_refs_openapi(dir, filename: "openapi.yaml", tag: "adhoc")
    suffix = SecureRandom.hex(4)
    registry = Skooma.create_registry(name: "ext_refs_#{tag}_#{suffix}")
    base_uri = "https://skoomarb.dev/fixtures/#{tag}/#{suffix}/"
    registry.add_source(base_uri, JSONSkooma::Sources::Local.new(dir))
    registry.schema(
      URI.parse("#{base_uri}#{filename}"),
      schema_class: Skooma::Objects::OpenAPI
    )
  end
end
