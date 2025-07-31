# frozen_string_literal: true

CONFIGS = {
  default: proc {},
  with_enforce_access_modes: ->(schema) do
    schema.enforce_access_modes = true
  end,
  with_use_patterns_for_path_matching: ->(schema) do
    schema.use_patterns_for_path_matching = true
  end
}.freeze

RSpec.describe Skooma do
  before(:all) { Skooma.create_registry }

  CONFIGS.each do |config_name, config_applier|
    context "with #{config_name} configuration" do
      spec_dir = File.expand_path("openapi_test_suite", __dir__)
      config_dir = File.join(spec_dir, config_name.to_s) if config_name != :default

      base_files = Dir["#{spec_dir}/*.json"].map { |f| [File.basename(f), f] }.to_h
      config_files = if config_dir && Dir.exist?(config_dir)
        Dir["#{config_dir}/*.json"].map { |f| [File.basename(f), f] }.to_h
      else
        {}
      end

      test_files = base_files.merge(config_files)

      test_files.values.each do |file|
        JSON.parse(File.read(file)).each do |test_case|
          context test_case["description"] do
            let(:schema) do
              Skooma::Objects::OpenAPI.new(test_case["schema"]).tap do |schema|
                config_applier.call(schema)
              end
            end

            it "contains a valid openapi schema" do
              result = schema.validate
              expect(result).to be_valid, <<~MSG
                Expected given schema to be valid.

                Schema:
                #{JSON.pretty_generate(test_case["schema"])}

                Validation output:
                #{JSON.pretty_generate(result.output(:detailed))}
              MSG
            end

            test_case["tests"].each do |test|
              it test["description"] do
                result = schema.evaluate(test["data"])

                expect(result.valid?).to eq(test["valid"]), <<~MSG
                  Expected given response to be #{test["valid"] ? "valid" : "invalid"}.

                  Response:
                  #{JSON.pretty_generate(test["data"])}

                  Validation output:
                  #{JSON.pretty_generate(result.output(:detailed))}
                MSG
              end
            end
          end
        end
      end
    end
  end
end
