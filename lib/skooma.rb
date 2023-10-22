# frozen_string_literal: true

require "json_skooma"
require "zeitwerk"

require_relative "skooma/inflector"

loader = Zeitwerk::Loader.for_gem
loader.inflector = Skooma::Inflector.new(__FILE__)
loader.setup

module Skooma
  DATA_DIR = File.join(__dir__, "..", "data")
  REGISTRY_NAME = "skooma_registry"

  class Error < StandardError; end

  JSONSkooma.register_dialect("oas-3.1", Dialects::OAS31)
  JSONSkooma::Formatters.register :skooma, OutputFormat

  class << self
    def create_registry(name: REGISTRY_NAME)
      JSONSkooma.create_registry("2020-12", "oas-3.1", name: name, assert_formats: true)
    end
  end
end
