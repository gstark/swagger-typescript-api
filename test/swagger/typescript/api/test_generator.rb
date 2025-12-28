# frozen_string_literal: true

require "test_helper"
require "tempfile"

class Swagger::Typescript::Api::TestGenerator < Minitest::Test
  def test_generates_typescript_from_openapi
    output_file = Tempfile.new(["types", ".ts"])

    config = Swagger::Typescript::Api::Configuration.new(
      input_path: File.expand_path("../../../../fixtures/petstore.yaml", __FILE__),
      output_path: output_file.path
    )

    generator = Swagger::Typescript::Api::Generator.new(config)
    output = generator.generate

    assert_includes output, "interface Pet {"
    assert_includes output, "id: number;"
    assert_includes output, "name: string;"
    assert_includes output, "tag?: string | null;"

    assert_includes output, "interface Category {"

    assert_includes output, "enum Status {"
    assert_includes output, "AVAILABLE"
    assert_includes output, "PENDING"
    assert_includes output, "SOLD"

    assert File.exist?(output_file.path)
    file_content = File.read(output_file.path)
    assert_equal output, file_content
  ensure
    output_file.close
    output_file.unlink
  end

  def test_raises_error_for_missing_input
    config = Swagger::Typescript::Api::Configuration.new(
      input_path: nil,
      output_path: "/tmp/output.ts"
    )

    generator = Swagger::Typescript::Api::Generator.new(config)

    assert_raises Swagger::Typescript::Api::ValidationError do
      generator.generate
    end
  end

  def test_type_prefix_and_suffix
    output_file = Tempfile.new(["types", ".ts"])

    config = Swagger::Typescript::Api::Configuration.new(
      input_path: File.expand_path("../../../../fixtures/petstore.yaml", __FILE__),
      output_path: output_file.path,
      type_prefix: "I",
      type_suffix: "Type"
    )

    generator = Swagger::Typescript::Api::Generator.new(config)
    output = generator.generate

    assert_includes output, "interface IPetType {"
    assert_includes output, "interface ICategoryType {"
  ensure
    output_file.close
    output_file.unlink
  end
end
