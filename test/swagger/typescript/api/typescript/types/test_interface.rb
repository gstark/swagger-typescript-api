# frozen_string_literal: true

require "test_helper"

class Swagger::Typescript::Api::TypeScript::Types::TestInterface < Minitest::Test
  def test_simple_interface
    properties = {
      "id" => Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :number),
      "name" => Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :string)
    }
    type = Swagger::Typescript::Api::TypeScript::Types::Interface.new(
      name: "User",
      properties: properties,
      required: ["id", "name"]
    )

    expected = "interface User {\n  id: number;\n  name: string;\n}"
    assert_equal expected, type.interface_definition
  end

  def test_optional_properties
    properties = {
      "id" => Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :number),
      "name" => Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :string)
    }
    type = Swagger::Typescript::Api::TypeScript::Types::Interface.new(
      name: "User",
      properties: properties,
      required: ["id"]
    )

    expected = "interface User {\n  id: number;\n  name?: string;\n}"
    assert_equal expected, type.interface_definition
  end

  def test_inline_object
    properties = {
      "x" => Swagger::Typescript::Api::TypeScript::Types::Primitive.new(type: :number)
    }
    type = Swagger::Typescript::Api::TypeScript::Types::Interface.new(
      properties: properties,
      required: ["x"]
    )

    expected = "{\n  x: number;\n}"
    assert_equal expected, type.inline_object
  end
end
