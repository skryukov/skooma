# frozen_string_literal: true

require "tmpdir"

RSpec.describe "External $ref error reporting" do
  def build_fixture_dir(files)
    dir = Dir.mktmpdir("skooma_ext_refs_")
    files.each { |name, content| File.write(File.join(dir, name), content) }
    dir
  end

  it "raises a descriptive error when an external file does not exist" do
    dir = build_fixture_dir(
      "openapi.yaml" => <<~YAML
        openapi: 3.1.0
        info: {title: t, version: "1"}
        paths:
          /x:
            get:
              responses:
                '200':
                  $ref: './missing.yaml#/Response'
      YAML
    )

    expect { load_external_refs_openapi(dir) }
      .to raise_error(JSONSkooma::Sources::Error, /missing\.yaml/)
  end

  it "raises a descriptive error when the fragment does not exist in the external file" do
    dir = build_fixture_dir(
      "openapi.yaml" => <<~YAML,
        openapi: 3.1.0
        info: {title: t, version: "1"}
        paths:
          /x:
            get:
              responses:
                '200':
                  $ref: './responses.yaml#/DoesNotExist'
      YAML
      "responses.yaml" => <<~YAML
        SomeOtherResponse:
          description: OK
      YAML
    )

    expect { load_external_refs_openapi(dir) }
      .to raise_error(JSONSkooma::RegistryError, /Could not resolve.*DoesNotExist/)
  end
end
