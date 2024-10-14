# frozen_string_literal: true

require_relative "test_app"

require "minitest/autorun"
require "rack/test"
require "skooma"

describe TestApp do
  include Rack::Test::Methods

  include Skooma::Minitest[File.join(__dir__, "openapi.yml"), coverage: :report]

  def app
    TestApp["bar"]
  end

  it "is valid OpenAPI document" do
    assert_is_valid_document(skooma_openapi_schema)
  end

  describe "GET /" do
    it "conforms to schema with 200 response code" do
      get "/"
      assert_conform_schema(200)
    end
  end

  describe "POST /" do
    it "conforms to schema with 201 response code" do
      post("/", JSON.generate("foo" => "bar"), "CONTENT_TYPE" => "application/json")

      assert_conform_schema(201)
    end

    it "conforms to schema with 400 response code" do
      post("/", JSON.generate("foo" => "baz"), "CONTENT_TYPE" => "application/json")

      assert_conform_response_schema(400)
    end
  end
end
