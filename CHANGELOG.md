# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

### Added

- Allow passing a custom coverage store to the RSpec/Minitest helpers via `coverage_store:` — any object implementing `load_data`, `save_data`, and `clear`. Useful for writing one coverage file per parallel CI runner and merging afterwards. ([@skryukov])
- Support object-valued path parameters (`simple`, `label`, and `matrix` styles, explode-aware) and `form`-style object query parameters. Exploded form objects (`?x=1&y=2`) are gathered by matching the schema's `properties` names; non-exploded forms flatten under the parameter's name (`?point=x,1,y,2`). Properties are coerced to their declared types. ([@skryukov])

- Support for external `$ref`s in OpenAPI documents. References like `$ref: './responses.yaml#/UsersResponse'` now resolve against the spec file's directory (or any source registered on the registry) and are wrapped with the appropriate OpenAPI object type — Response, Parameter, Header, RequestBody, PathItem, or a plain JSON Schema for `schema:` refs. Chained and self-recursive external refs are supported. ([@skryukov])
- Support array-valued query parameters: respect the `style` and `explode` keywords (`form`, `spaceDelimited`, and `pipeDelimited` styles), coerce array items to the declared `items` type, and map the non-standard bracket convention (`ids[]=1&ids[]=2`) to array params. ([@dslh])
- Support object-valued query parameters declared with the `deepObject` style (`filter[id]=1&filter[name]=foo`), coercing each property to its declared type. Parameter coercion now descends into array items (positional `prefixItems` first, then `items`) and object properties (`properties` first, then `additionalProperties`), while request/response bodies keep their JSON-native types.
- Support array-valued header (`simple` style) and cookie (`form` style) parameters, splitting the delimited value and coercing each item to the declared `items` type.
- Support cookie parameters, which were previously ignored entirely.
- Support array-valued path parameters across the `simple`, `label`, and `matrix` styles (with `explode`), coercing each item to the declared `items` type.
- Parse `content`-typed parameters (e.g. `content: {application/json: …}`) using the parameter's own media type before validation, instead of validating the raw string against a media type taken from the response. **Behavior change:** such values are now decoded per their media type (e.g. JSON), so a value that previously passed as a raw string may need to be sent in its serialized form (e.g. `"100"` rather than `100` for a JSON string).

### Changed

- Bumped minimum `json_skooma` to `~> 0.2.7` for the new typed `UnexpectedSchemaClassError` and public `Registry#load_json` (0.2.6 was yanked due to a packaging issue). ([@skryukov])

## [0.3.8] - 2026-04-16

### Fixed

- Minitest 6 compatibility ([@visini])

## [0.3.7] - 2025-10-31

### Added

- Add support for symbolic response codes. ([@alexkalderimis])
- Add OpenAPI 3.1.2 & 3.2.0 schemas to enable schema validation. ([@skryukov])

## [0.3.6] - 2025-09-04

### Added

- Add OpenAPI 3.1.1 schemas to enable schema validation. ([@Envek])

### Fixed

- Fix examples and callbacks support in Components. ([@goodtouch])

## [0.3.5] - 2025-07-31

### Fixed

- Fix the Enforce Access mode with additional properties. ([@aburgel])
- Introduce coverage storage to fix Minitest parallel workers reports. ([@skarlcf])
- Introduce `use_patterns_for_path_matching` option to allow using `path` patterns for path matching. ([@jandouwebeekman])

    ```ruby
    # spec/rails_helper.rb

    RSpec.configure do |config|
      # To enable path patterns, pass `use_patterns_for_path_matching: true` option:
      config.include Skooma::RSpec[Rails.root.join("docs", "openapi.yml"), use_patterns_for_path_matching: true], type: :request
    end
    ```

## [0.3.4] - 2025-01-14

### Added

- Experimental support for `readOnly` and `writeOnly` keywords. ([@skryukov])

    ```ruby
    # spec/rails_helper.rb
    
    RSpec.configure do |config|
      # To enable support for readOnly and writeOnly keywords, pass `enforce_access_modes: true` option:
      config.include Skooma::RSpec[Rails.root.join("docs", "openapi.yml"), enforce_access_modes: true], type: :request
    end
    ```
- Support fallback parsers for vendor-specific media types. ([@pvcarrera], [@skryukov])

## [0.3.3] - 2024-10-14

### Fixed

- Fix coverage for Minitest. ([@skryukov])

## [0.3.2] - 2024-06-24

### Fixed

- Fix deprecation `MiniTest::Unit.after_tests is now Minitest.after_run`. ([@barnaclebarnes])
- Exclude test helpers from eager loading. ([@skryukov])
- Update oas-3.1 base schema. ([@skryukov])

## [0.3.1] - 2024-04-11

### Added

- Add coverage for tested API operations. ([@skryukov])
 
    ```ruby
    
    # spec/rails_helper.rb
    
    RSpec.configure do |config|
      # To enable coverage, pass `coverage: :report` option,
      # and to raise an error when an operation is not covered, pass `coverage: :strict` option:
      config.include Skooma::RSpec[Rails.root.join("docs", "openapi.yml"), coverage: :report], type: :request
    end
    ```

    ```shell
    $ bundle exec rspec
    # ...
    OpenAPI schema /openapi.yml coverage report: 110 / 194 operations (56.7%) covered.
    Uncovered paths:
    GET /api/uncovered 200
    GET /api/partially_covered 403
    # ...
    ```

## [0.3.0] - 2024-04-09

### Changed

- BREAKING CHANGE: Pass `headers` parameter to registered `BodyParsers`. ([@skryukov])

    ```ruby
    # Before:
    Skooma::BodyParsers.register("application/xml", ->(body) { Hash.from_xml(body) })
    # After:
    Skooma::BodyParsers.register("application/xml", ->(body, headers:) { Hash.from_xml(body) })
    ```
### Fixed

- Fix wrong path when combined with Rails exceptions_app. ([@ursm])

## [0.2.3] - 2024-01-18

### Added

- Add support for multiple OpenAPI documents. ([@skryukov])

### Fixed

- Fix `Skooma::Error: Missing name key /request` by setting `content` and `required` keyword dependencies. ([@skryukov])

## [0.2.2] - 2024-01-04

### Added

- Add support for APIs mounted under a path prefix. ([@skryukov])

    ```ruby
    # spec/rails_helper.rb
    
    RSpec.configure do |config|
      # ...
      path_to_openapi = Rails.root.join("docs", "openapi.yml")
      # pass path_prefix option if your API is mounted under a prefix:
      config.include Skooma::RSpec[path_to_openapi, path_prefix: "/internal/api"], type: :request
    end
    ```

### Changed

- Bump `json_skooma` version to `~> 0.2.0`. ([@skryukov])

### Fixed

- Better checks to automatic request/response detection to prevent methods overrides via RSpec helpers (i.e. `subject(:response)`). ([@skryukov])
- Fail response validation when expected response code or `responses` keyword aren't listed. ([@skryukov])

## [0.2.1] - 2023-10-23

### Fixed

- Raise error when parameter attributes misses required keys. ([@skryukov])
- Fix output format. ([@skryukov])

## [0.2.0] - 2023-10-23

### Added

- Add `minitest` and `rake-test` support. ([@skryukov])
- Add `discriminator` keyword support. ([@skryukov])

### Fixed

- Fix Zeitwerk eager loading. ([@skryukov])

## [0.1.0] - 2023-09-27

### Added

- Initial implementation. ([@skryukov])

[@aburgel]: https://github.com/aburgel
[@alexkalderimis]: https://github.com/alexkalderimis
[@barnaclebarnes]: https://github.com/barnaclebarnes
[@dslh]: https://github.com/dslh
[@Envek]: https://github.com/Envek
[@goodtouch]: https://github.com/goodtouch
[@jandouwebeekman]: https://github.com/jandouwebeekman
[@pvcarrera]: https://github.com/pvcarrera
[@skarlcf]: https://github.com/skarlcf
[@skryukov]: https://github.com/skryukov
[@ursm]: https://github.com/ursm
[@visini]: https://github.com/visini

[Unreleased]: https://github.com/skryukov/skooma/compare/v0.3.8...HEAD
[0.3.8]: https://github.com/skryukov/skooma/compare/v0.3.7...v0.3.8
[0.3.7]: https://github.com/skryukov/skooma/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/skryukov/skooma/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/skryukov/skooma/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/skryukov/skooma/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/skryukov/skooma/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/skryukov/skooma/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/skryukov/skooma/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/skryukov/skooma/compare/v0.2.3...v0.3.0
[0.2.3]: https://github.com/skryukov/skooma/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/skryukov/skooma/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/skryukov/skooma/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/skryukov/skooma/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/skryukov/skooma/commits/v0.1.0

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
