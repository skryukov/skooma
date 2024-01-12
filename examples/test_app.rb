# frozen_string_literal: true

require "sinatra"
require "json"

module TestApp
  def self.[](value)
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
    end
  end
end
