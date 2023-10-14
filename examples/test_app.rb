# frozen_string_literal: true

require "sinatra"
require "json"

TestApp = Sinatra.new do
  get "/" do
    content_type :json
    JSON.generate({"foo" => "bar"})
  end

  post "/" do
    content_type :json
    data = JSON.parse request.body.read
    if data["foo"] == "bar"
      status 201
      JSON.generate({"foo" => "bar"})
    else
      status 400
      JSON.generate({"message" => "foo must be bar"})
    end
  end
end
