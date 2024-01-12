# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "rails/test_unit/railtie"

require_relative "../test_app"

class RailsApp < Rails::Application
  config.load_defaults Rails::VERSION::STRING.to_f
  config.eager_load = false
  config.logger = Logger.new(nil)

  routes.append do
    mount TestApp["bar"], at: "/bar", as: :bar_api
    mount TestApp["baz"], at: "/baz", as: :baz_api
  end
end

RailsApp.initialize!
