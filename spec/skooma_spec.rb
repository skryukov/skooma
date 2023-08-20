# frozen_string_literal: true

RSpec.describe Skooma do
  before(:all) { Skooma.create_registry }

  Dir["#{File.expand_path("../openapi_test_suite", __FILE__)}/*.json"].each do |file|
    JSON.parse(File.read(file)).each do |test_case|
      context test_case["description"] do
        let(:schema) do
          Skooma::Objects::OpenAPI.new(test_case["schema"])
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
