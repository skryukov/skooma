# frozen_string_literal: true

require "sinatra"
require "json"

module TestApp
  def self.[](value)
    things = [
      {"foo" => "bar"},
      {"foo" => "baz"},
      {"foo" => "qux"},
      {"foo" => "quux"},
      {"foo" => "corge"},
      {"foo" => "grault"},
      {"foo" => "garply"},
      {"foo" => "waldo"},
      {"foo" => "fred"},
      {"foo" => "plugh"},
      {"foo" => "xyzzy"},
      {"foo" => "thud"},
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

      get "/things" do
        content_type :json
        JSON.generate(things)
      end

      get /\/things([\d]+)/ do |id|
        puts "not recognized"
        content_type :json
        JSON.generate(things[id.to_i])
      end

      get "/things/first5" do
        puts "recognized"
        content_type :json
        JSON.generate(things[0..4])
      end
    end
  end
end
