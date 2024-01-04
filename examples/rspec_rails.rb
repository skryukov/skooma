# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails"
  gem "rspec"
  gem "rspec-rails"
  gem "skooma", (ENV["CI"] == "1") ? {path: File.join(__dir__, "..")} : {}
  gem "sinatra"
end

require_relative "test_app"

require "rails"
require "action_controller/railtie"
require "rails/test_unit/railtie"

require "rspec/rails"
require "rspec/autorun"
require "skooma"

ENV["RAILS_ENV"] = "test"

RSpec.configure do |config|
  path_to_openapi = File.join(__dir__, "openapi.yml")
  # You can use different RSpec filters if you want to test different API descriptions.
  # Check RSpec's config.define_derived_metadata for better UX.
  config.include Skooma::RSpec[path_to_openapi], :root_api, type: :request
  config.include Skooma::RSpec[path_to_openapi, path_prefix: "/custom/path/to/api"], :prefixed_api, type: :request
end

class RailsApp < Rails::Application
  config.load_defaults Rails::VERSION::STRING.to_f
  config.eager_load = false
  config.logger = Logger.new(nil)

  routes.append do
    mount TestApp, at: "/"
    mount TestApp, at: "/custom/path/to/api", as: :prefixed_api
  end
end

RailsApp.initialize!

describe "Rails app" do
  describe "OpenAPI document", type: :request do
    subject(:schema) { skooma_openapi_schema }

    it { is_expected.to be_valid_document }
  end

  describe "Prefixed API", :root_api, type: :request do
    describe "GET /" do
      subject { get "/" }

      it { is_expected.to conform_schema(200) }

      it "returns correct response" do
        subject
        expect(response.parsed_body).to eq({"foo" => "bar"})
      end
    end

    describe "POST /" do
      subject { post("/", params: body, as: :json) }

      let(:body) { {foo: "bar"} }

      it { is_expected.to conform_schema(201) }

      context "with invalid params" do
        let(:body) { {foo: "baz"} }

        it { is_expected.to conform_response_schema(400) }
      end
    end
  end

  describe "Prefixed API", :prefixed_api, type: :request do
    describe "GET prefixed /" do
      subject { get "/custom/path/to/api" }

      it { is_expected.to conform_schema(200) }

      it "returns correct response" do
        subject
        expect(response.parsed_body).to eq({"foo" => "bar"})
      end
    end

    describe "POST prefixed /" do
      subject { post("/custom/path/to/api", params: body, as: :json) }

      let(:body) { {foo: "bar"} }

      it { is_expected.to conform_schema(201) }

      context "with invalid params" do
        let(:body) { {foo: "baz"} }

        it { is_expected.to conform_response_schema(400) }
      end
    end
  end
end
