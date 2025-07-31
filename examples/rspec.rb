# frozen_string_literal: true

ENV["APP_ENV"] = "test"

require_relative "test_app"

require "rspec/autorun"
require "rack/test"
require "skooma"

RSpec.configure do |config|
  path_to_openapi = File.join(__dir__, "openapi.yml")
  config.include Skooma::RSpec[path_to_openapi, coverage: :strict, use_patterns_for_path_matching: true], type: :request

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

  describe "GET /items" do
    subject { get "/items" }

    it { is_expected.to conform_schema(200) }
  end

  describe "GET /items/{id}" do
    subject { get "/items/1" }

    it { is_expected.to conform_schema(200) }
  end

  describe "GET /items/first5.json" do
    subject { get "/items/first5.json" }

    it { is_expected.to conform_schema(200) }
  end
end
