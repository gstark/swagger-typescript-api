# frozen_string_literal: true

require "test_helper"

class Swagger::Typescript::Api::TypeScript::Types::TestEnum < Minitest::Test
  def test_named_enum
    type = Swagger::Typescript::Api::TypeScript::Types::Enum.new(
      name: "Status",
      values: ["active", "inactive"]
    )

    expected = "enum Status {\n  ACTIVE = \"active\",\n  INACTIVE = \"inactive\",\n}"
    assert_equal expected, type.enum_definition
  end

  def test_inline_union
    type = Swagger::Typescript::Api::TypeScript::Types::Enum.new(
      values: ["available", "pending", "sold"]
    )

    assert_equal "\"available\" | \"pending\" | \"sold\"", type.to_typescript
  end

  def test_numeric_enum
    type = Swagger::Typescript::Api::TypeScript::Types::Enum.new(
      name: "Priority",
      values: [1, 2, 3],
      string_enum: false
    )

    expected = "enum Priority {\n  _1 = 1,\n  _2 = 2,\n  _3 = 3,\n}"
    assert_equal expected, type.enum_definition
  end
end
