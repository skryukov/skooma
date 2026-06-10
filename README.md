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

### Learn more

- [Let there be docs! A documentation-first approach to Rails API development](https://evilmartians.com/chronicles/let-there-be-docs-a-documentation-first-approach-to-rails-api-development)

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

  # OR pass path_prefix option if your API is mounted under a prefix:
  config.include Skooma::RSpec[path_to_openapi, path_prefix: "/internal/api"], type: :request

  # To enable coverage, pass `coverage: :report` option,
  # and to raise an error when an operation is not covered, pass `coverage: :strict` option:
  config.include Skooma::RSpec[path_to_openapi, coverage: :report], type: :request
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
path_to_openapi = Rails.root.join("docs", "openapi.yml")
ActionDispatch::IntegrationTest.include Skooma::Minitest[path_to_openapi]

# OR pass path_prefix option if your API is mounted under a prefix:
ActionDispatch::IntegrationTest.include Skooma::Minitest[path_to_openapi, path_prefix: "/internal/api"], type: :request

# To enable coverage, pass `coverage: :report` option,
# and to raise an error when an operation is not covered, pass `coverage: :strict` option:
ActionDispatch::IntegrationTest.include Skooma::Minitest[path_to_openapi, coverage: :report], type: :request

# EXPERIMENTAL
# To enable support for readOnly and writeOnly keywords, pass `enforce_access_modes: true` option:
ActionDispatch::IntegrationTest.include Skooma::Minitest[path_to_openapi, enforce_access_modes: true], type: :request

# To enable custom regex patterns for path parameters, pass `use_patterns_for_path_matching: true` option.
ActionDispatch::IntegrationTest.include Skooma::Minitest[path_to_openapi, use_patterns_for_path_matching: true], type: :request
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

### Splitting specs across files

Skooma resolves external `$ref`s relative to the OpenAPI document's directory, so you can split a large spec into multiple files:

```yaml
# docs/openapi.yaml
paths:
  /users:
    get:
      responses:
        '200':
          $ref: './responses.yaml#/UsersResponse'
  /health:
    $ref: './paths.yaml#/Health'
```

References are wrapped with the appropriate OpenAPI object type based on context — `$ref` inside `responses` loads as a Response, inside `parameters` as a Parameter, inside `schema` as a JSON Schema, and so on. Chained (A → B → C) and self-recursive schemas work out of the box.

Only local files are resolved by default. To load refs from other sources (e.g. HTTP), register a source on the registry:

```ruby
schema = Skooma::Minitest[path_to_openapi].schema
schema.registry.add_source(
  "https://example.com/schemas/",
  JSONSkooma::Sources::Remote.new("https://example.com/schemas/")
)
```

### Array query parameters

Skooma deserializes array-valued query parameters according to their `style` and `explode`
keywords (`form`, `spaceDelimited`, and `pipeDelimited` styles are supported),
and coerces each item to the type declared in the `items` schema:

```yaml
- in: query
  name: ids
  schema:
    type: array
    items:
      type: integer
```

```
GET /things?ids=1&ids=2&ids=3 # ids => [1, 2, 3]
```

As a convenience, the non-standard Rails/Rack bracket convention is also recognized:
`GET /things?ids[]=1&ids[]=2` matches the array parameter named `ids`.
The bracket form is only used when the parameter declares `type: array` and
the query string contains no exact `ids` key.

### Object query parameters

Skooma deserializes object-valued query parameters declared with the `deepObject`
style, gathering the bracketed members and coercing each property to the type
declared in its `properties` schema:

```yaml
- in: query
  name: filter
  style: deepObject
  explode: true
  schema:
    type: object
    properties:
      id:
        type: integer
      name:
        type: string
```

```
GET /things?filter[id]=1&filter[name]=foo # filter => { "id" => 1, "name" => "foo" }
```

The default `form` style is also supported. Exploded form objects (the default)
drop the parameter name — each property declared in the schema becomes its own
query key — while non-exploded objects flatten under the parameter's name:

```
GET /things?x=1&y=2        # form, explode:  point => { "x" => 1, "y" => 2 }
GET /things?point=x,1,y,2  # form:           point => { "x" => 1, "y" => 2 }
```

Note that exploded form objects are gathered by matching the schema's
`properties` names, so members allowed only via `additionalProperties` are not
recognized.

### Header and cookie parameters

Array-valued header (`simple` style) and cookie (`form` style) parameters are
deserialized from their delimited form and each item is coerced to the declared
`items` type:

```
X-Ids: 1,2,3            # X-Ids  => [1, 2, 3]
Cookie: ids=1,2,3       # ids    => [1, 2, 3]
```

### Path parameters

Array-valued path parameters are deserialized according to their `style`
(`simple`, `label`, `matrix`) and `explode` keywords, with each item coerced to
the declared `items` type:

```
GET /things/1,2,3          # simple:            id => [1, 2, 3]
GET /things/.1.2.3         # label, explode:    id => [1, 2, 3]
GET /things/;id=1;id=2     # matrix, explode:   id => [1, 2]
```

Object-valued path parameters flatten their properties into the segment and are
rebuilt with each property coerced via the `properties` schema:

```
GET /points/x,1,y,2        # simple:            point => { "x" => 1, "y" => 2 }
GET /points/x=1,y=2        # simple, explode:   point => { "x" => 1, "y" => 2 }
GET /points/;x=1;y=2       # matrix, explode:   point => { "x" => 1, "y" => 2 }
```

## Alternatives

- [openapi_first](https://github.com/ahx/openapi_first)
- [committee](https://github.com/interagent/committee)

## Feature plans

- Full OpenAPI 3.1.0 support:
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
