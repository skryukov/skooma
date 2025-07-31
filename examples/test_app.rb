# frozen_string_literal: true

require "sinatra"
require "json"

module TestApp
  def self.[](value)
    items = [
      {"foo" => value},
      {"foo" => "qux"},
      {"foo" => "quux"},
      {"foo" => "corge"},
      {"foo" => "grault"},
      {"foo" => "garply"},
      {"foo" => "waldo"},
      {"foo" => "fred"},
      {"foo" => "plugh"},
      {"foo" => "xyzzy"},
      {"foo" => "thud"}
    ]

    Sinatra.new do
      get "/" do
        content_type :json
        JSON.generate({"foo" => value})
      end

      post "/" do
        content_type :json
        data = JSON.parse request.body.read
        if data["foo"] == value
          status 201
          JSON.generate({"foo" => value})
        else
          status 400
          JSON.generate({"message" => "foo must be #{value}"})
        end
      end

      get "/items" do
        content_type :json
        JSON.generate(items)
      end

      get(/\/items\/(\d+)/) do |id|
        content_type :json
        JSON.generate(items[id.to_i])
      end

      get(/\/items\/first5((\.(xml|json))?)/) do
        format = params["captures"]
        if format != ".xml"
          content_type :json
          JSON.generate(items[0..4])
        end
      end
    end
  end
end
