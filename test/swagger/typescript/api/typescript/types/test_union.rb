# frozen_string_literal: true

require "test_helper"

class Swagger::Typescript::Api::TypeScript::Types::TestUnion < Minitest::Test
  def test_simple_union
    types = [
      Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :string),
      Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :number)
    ]
    type = Swagger::Typescript::Api::TypeScript::Types::Union.new(types: types)

    assert_equal "string | number", type.to_typescript
  end

  def test_empty_union
    type = Swagger::Typescript::Api::TypeScript::Types::Union.new(types: [])

    assert_equal "never", type.to_typescript
  end

  def test_reference_union
    types = [
      Swagger::Typescript::Api::TypeScript::Types::Reference.new(ref_name: "Cat"),
      Swagger::Typescript::Api::TypeScript::Types::Reference.new(ref_name: "Dog")
    ]
    type = Swagger::Typescript::Api::TypeScript::Types::Union.new(types: types)

    assert_equal "Cat | Dog", type.to_typescript
  end
end
