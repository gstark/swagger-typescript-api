# frozen_string_literal: true

require "test_helper"

class Swagger::Typescript::Api::TypeScript::Types::TestPrimitive < Minitest::Test
  def test_string_type
    type = Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :string)

    assert_equal "string", type.to_typescript
  end

  def test_number_type
    type = Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :number)

    assert_equal "number", type.to_typescript
  end

  def test_boolean_type
    type = Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :boolean)

    assert_equal "boolean", type.to_typescript
  end

  def test_nullable_type
    type = Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :string, nullable: true)

    assert_equal "string | null", type.to_typescript
  end

  def test_invalid_type_raises_error
    assert_raises ArgumentError do
      Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :invalid)
    end
  end
end
