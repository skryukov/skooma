# frozen_string_literal: true

RSpec.describe "External $ref resolution" do
  Dir["#{ExternalRefsHelpers::FIXTURES_DIR}/*"].sort.each do |case_dir|
    next unless File.directory?(case_dir)
    tests_file = File.join(case_dir, "tests.json")
    next unless File.exist?(tests_file)
    next unless Dir["#{case_dir}/openapi.{yaml,yml,json}"].first

    case_name = File.basename(case_dir)

    context "fixture: #{case_name}" do
      let(:schema) { load_external_refs_fixture(case_name) }

      JSON.parse(File.read(tests_file)).each do |test_case|
        context test_case["description"] do
          it "contains a valid openapi schema" do
            result = schema.validate
            expect(result).to be_valid, <<~MSG
              Expected schema to be valid.

              Validation output:
              #{JSON.pretty_generate(result.output(:detailed))}
            MSG
          end

          test_case["tests"].each do |test|
            it test["description"] do
              result = schema.evaluate(test["data"])

              expect(result.valid?).to eq(test["valid"]), <<~MSG
                Expected response to be #{test["valid"] ? "valid" : "invalid"}.

                Data:
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
