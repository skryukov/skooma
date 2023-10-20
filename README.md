# Skooma – Sugar for your APIs

[![Gem Version](https://badge.fury.io/rb/skooma.svg)](https://rubygems.org/gems/skooma)
[![Ruby](https://github.com/skryukov/skooma/actions/workflows/main.yml/badge.svg)](https://github.com/skryukov/skooma/actions/workflows/main.yml)

<img align="right" height="150" width="150" title="Skooma logo" src="./assets/logo.svg">

Skooma is a Ruby library for validating API implementations against OpenAPI documents.

### Features

- Supports OpenAPI 3.1.0
- Supports OpenAPI document validation
- Supports request/response validations against OpenAPI document
- Includes RSpec and Minitest helpers

<a href="https://evilmartians.com/?utm_source=skooma&utm_campaign=project_page">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add skooma

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install skooma

## Usage

Skooma provides `rspec` and `minitest` helpers for validating OpenAPI documents and requests/responses against them.
Skooma helpers are designed to be used with `rails` request specs or `rack-test`.

### RSpec

#### Configuration

```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
  # ...
  path_to_openapi = Rails.root.join("docs", "openapi.yml")
  config.include Skooma::RSpec[path_to_openapi], type: :request
end
```

#### Validate OpenAPI document

```ruby
# spec/openapi_spec.rb

require "rails_helper"

describe "OpenAPI document", type: :request do
  subject(:schema) { skooma_openapi_schema }

  it { is_expected.to be_valid_document }
end
```

#### Validate request

```ruby
# spec/requests/feed_spec.rb

require "rails_helper"

describe "/animals/:animal_id/feed" do  
  let(:animal) { create(:animal, :unicorn) }
  
  describe "POST" do
    subject { post "/animals/#{animal.id}/feed", body:, as: :json }
    
    let(:body) { {food: "apple", quantity: 3} }

    it { is_expected.to conform_schema(200) }

    context "with wrong food type" do
      let(:body) { {food: "wood", quantity: 1} }
    
      it { is_expected.to conform_schema(422) }
    end
  end
end

# Validation Result:
#
#  {"valid"=>false,
#   "instanceLocation"=>"",
#   "keywordLocation"=>"",
#   "absoluteKeywordLocation"=>"urn:uuid:1b4b39eb-9b93-4cc1-b6ac-32a25d9bff50#",
#   "errors"=>
#     [{"instanceLocation"=>"",
#       "keywordLocation"=>
#         "/paths/~1animals~1{animalId}~1feed/post/responses/200"/
#           "/content/application~1json/schema/required",
#       "error"=>
#         "The object is missing required properties"/
#           " [\"animalId\", \"food\", \"amount\"]"}]}
```

### Minitest

#### Configuration

```ruby
# test/test_helper.rb

ActionDispatch::IntegrationTest.include Skooma::Minitest[Rails.root.join("docs", "openapi.yml")]
```

#### Validate OpenAPI document

```ruby
# test/openapi_test.rb

require "test_helper"

class OpenapiTest < ActionDispatch::IntegrationTest
  test "is valid OpenAPI document" do
    assert_is_valid_document(skooma_openapi_schema)
  end
end
```

#### Validate request

```ruby
# test/integration/items_test.rb

require "test_helper"

class ItemsTest < ActionDispatch::IntegrationTest
  test "GET /" do
    get "/"
    assert_conform_schema(200)
  end

  test "POST / conforms to schema with 201 response code" do
    post "/", params: {foo: "bar"}, as: :json
    assert_conform_schema(201)
  end

  test "POST / conforms to schema with 400 response code" do
    post "/", params: {foo: "baz"}, as: :json
    assert_conform_response_schema(400)
  end
end
```

## Alternatives

- [openapi_first](https://github.com/ahx/openapi_first)
- [committee](https://github.com/interagent/committee)

## Feature plans

- Full support for external `$ref`s
- Full OpenAPI 3.1.0 support:
  - respect `style` and `explode` keywords
  - xml
- Callbacks and webhooks validations
- Example validations
- Ability to plug in custom X-*** keyword classes

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skryukov/skooma.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
