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
  config.include Skooma::RSpec[path_to_openapi], type: :request
end

class RailsApp < Rails::Application
  config.load_defaults Rails::VERSION::STRING.to_f
  config.eager_load = false
  config.logger = Logger.new(nil)

  routes.append do
    mount TestApp, at: "/"
  end
end

RailsApp.initialize!

describe "Rails app", type: :request do
  describe "OpenAPI document", type: :request do
    subject(:schema) { skooma_openapi_schema }

    it { is_expected.to be_valid_document }
  end

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
