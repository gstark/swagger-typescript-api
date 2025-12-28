# frozen_string_literal: true

require "test_helper"

class Swagger::Typescript::Api::TypeScript::Types::TestArray < Minitest::Test
  def test_simple_array
    item_type = Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :string)
    type = Swagger::Typescript::Api::TypeScript::Types::Array.new(item_type: item_type)

    assert_equal "string[]", type.to_typescript
  end

  def test_array_of_references
    item_type = Swagger::Typescript::Api::TypeScript::Types::Reference.new(ref_name: "Pet")
    type = Swagger::Typescript::Api::TypeScript::Types::Array.new(item_type: item_type)

    assert_equal "Pet[]", type.to_typescript
  end

  def test_array_of_union_adds_parentheses
    union = Swagger::Typescript::Api::TypeScript::Types::Union.new(
      types: [
        Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :string),
        Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :number)
      ]
    )
    type = Swagger::Typescript::Api::TypeScript::Types::Array.new(item_type: union)

    assert_equal "(string | number)[]", type.to_typescript
  end
end
