# frozen_string_literal: true

require_relative "lib/skooma/version"

Gem::Specification.new do |spec|
  spec.name = "skooma"
  spec.version = Skooma::VERSION
  spec.authors = ["Svyatoslav Kryukov"]
  spec.email = ["me@skryukov.dev"]

  spec.summary = "I bring some sugar for your APIs."
  spec.description = "I bring some sugar for your APIs."
  spec.homepage = "https://github.com/skryukov/skooma"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => "#{spec.homepage}/blob/main/README.md",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.glob("lib/**/*") + Dir.glob("data/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "zeitwerk", "~> 2.6"
  spec.add_runtime_dependency "json_skooma", "~> 0.1"
end
