# frozen_string_literal: true

module Skooma
  class Inflector < Zeitwerk::GemInflector
    STATIC_MAPPING = {
      "oas_3_1" => "OAS31",
      "openapi" => "OpenAPI",
      "rspec" => "RSpec"
    }

    def camelize(basename, _abspath)
      if basename.include?("json_")
        super.gsub("Json", "JSON")
      else
        STATIC_MAPPING[basename] || super
      end
    end
  end
end
