# RSpec Rails Example

This is an example Rails app that uses Skooma with multiple openapi documents.

First, we need to define the OpenAPI documents we want to use:

```ruby
# rails_helper.rb
RSpec.configure do |config|
  # You can use different RSpec filters if you want to test different API descriptions.
  # Check RSpec's config.define_derived_metadata for better UX.
  config.include Skooma::RSpec[bar_openapi, path_prefix: "/bar"], :bar_api
  config.include Skooma::RSpec[baz_openapi, path_prefix: "/baz"], :baz_api
end
```

Next, we can write our specs and mark them with the appropriate RSpec filter:

```ruby
# spec/requests/bar/bar_spec.rb
describe "Bar API", :bar_api, type: :request do
  describe "GET /bar" do
    subject { get "/bar" }

    it { is_expected.to conform_schema(200) }
  end
end
```

To avoid having to specify the RSpec filter on every spec, you can use RSpec's `config.define_derived_metadata`:

```ruby
# rails_helper.rb
RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/requests/bar}) do |metadata|
    metadata[:bar_api] = true
  end
end
```

## Running the example

```bash
bundle install
bundle exec rspec
```
