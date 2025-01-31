ENV["RAILS_ENV"] = "test"
ENV["APP_ENV"] = "test"

require_relative "../app"

require "rspec/rails"
require "skooma"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # bar_openapi = File.join(__dir__, "..", "docs", "bar_openapi.yml")
  bar_openapi = File.join(__dir__, "..", "..", "openapi.yml")
  # baz_openapi = File.join(__dir__, "..", "docs", "baz_openapi.yml")
  baz_openapi = File.join(__dir__, "..", "..", "openapi.yml")

  # You can use different RSpec filters if you want to test different API descriptions.
  # Check RSpec's config.define_derived_metadata for better UX.
  config.include Skooma::RSpec[bar_openapi, path_prefix: "/bar", coverage: :strict], :bar_api
  config.include Skooma::RSpec[baz_openapi, path_prefix: "/baz", coverage: :strict], :baz_api
end
