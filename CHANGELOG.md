# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]


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

[@skryukov]: https://github.com/skryukov

[Unreleased]: https://github.com/skryukov/skooma/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/skryukov/skooma/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/skryukov/skooma/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/skryukov/skooma/commits/v0.1.0

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
