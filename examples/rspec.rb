# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
  gem "rack-test"
  gem "skooma", (ENV["CI"] == "1") ? {path: File.join(__dir__, "..")} : {}
  gem "sinatra"
end

require_relative "test_app"

require "rspec/autorun"
require "skooma"

RSpec.configure do |config|
  path_to_openapi = File.join(__dir__, "openapi.yml")
  config.include Skooma::RSpec[path_to_openapi, coverage: :strict], type: :request

  config.include Rack::Test::Methods, type: :request
end

describe TestApp, type: :request do
  def app
    TestApp["bar"]
  end

  describe "OpenAPI document", type: :request do
    subject(:schema) { skooma_openapi_schema }

    it { is_expected.to be_valid_document }
  end

  describe "GET /" do
    subject { get "/" }

    it { is_expected.to conform_schema(200) }
  end

  describe "POST /" do
    subject { post("/", JSON.generate(body), "CONTENT_TYPE" => "application/json") }

    let(:body) { {foo: "bar"} }

    it { is_expected.to conform_schema(201) }

    context "with invalid params" do
      let(:body) { {foo: "baz"} }

      it { is_expected.to conform_response_schema(400) }
    end
  end
end
