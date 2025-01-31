{"openapi" => "3.1.0",
 "info" => {"title" => "OpenAPI Sample", "version" => "1.0.0"},
 "paths" =>
  {"/" =>
    {"get" =>
      {"parameters" => [],
       "responses" =>
        {"200" =>
          {"description" => "OK",
           "content" =>
            {"application/json" =>
              {"schema" => {"$ref" => "#/components/schemas/Item"}}}}}},
     "post" =>
      {"parameters" => [],
       "requestBody" =>
        {"content" =>
          {"application/json" =>
            {"schema" => {"$ref" => "#/components/schemas/Item"}}}},
       "responses" =>
        {"201" =>
          {"description" => "OK",
           "content" =>
            {"application/json" =>
              {"schema" => {"$ref" => "#/components/schemas/Item"}}}},
         "400" =>
          {"description" => "Bad Request",
           "content" =>
            {"application/json" =>
              {"schema" => {"$ref" => "#/components/schemas/Error"}}}}}}},
   "/things" =>
    {"get" =>
      {"parameters" => [],
       "responses" =>
        {"200" =>
          {"description" => "OK",
           "content" =>
            {"application/json" =>
              {"schema" =>
                {"items" => {"$ref" => "#/components/schemas/Item"}}}}}}}},
   "/things/{id}" =>
    {"get" =>
      {"parameters" =>
        [{"name" => "id",
          "in" => "path",
          "schema" => {"type" => "string", "pattern" => "\\d+"}}],
       "responses" =>
        {"200" =>
          {"description" => "OK",
           "content" =>
            {"application/json" =>
              {"schema" => {"$ref" => "#/components/schemas/Item"}}}}}}},
   "/things/first5{format}" =>
    {"get" =>
      {"parameters" =>
        [{"name" => "format",
          "in" => "path",
          "schema" => {"type" => "string", "pattern" => "(.(xml|json))?"}}],
       "responses" =>
        {"200" =>
          {"description" => "OK",
           "content" =>
            {"application/json" =>
              {"schema" =>
                {"items" => {"$ref" => "#/components/schemas/Item"}}}}}}}}},
 "components" =>
  {"schemas" =>
    {"Item" =>
      {"type" => "object",
       "properties" =>
        {"foo" =>
          {"type" => "string",
           "enum" =>
            ["bar",
             "baz",
             "qux",
             "quux",
             "corge",
             "grault",
             "garply",
             "waldo",
             "fred",
             "plugh",
             "xyzzy",
             "thud"]}},
       "unevaluatedProperties" => false,
       "required" => ["foo"]},
     "Error" =>
      {"type" => "object",
       "properties" => {"message" => {"type" => "string"}},
       "unevaluatedProperties" => false,
       "required" => ["message"]}}}}