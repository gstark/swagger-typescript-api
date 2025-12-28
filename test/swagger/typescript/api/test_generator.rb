# frozen_string_literal: true

require "json"
require "tempfile"
require "test_helper"

class Swagger::Typescript::Api::TestGenerator < Minitest::Test
  def test_generates_typescript_from_openapi
    output_file = Tempfile.new(["types", ".ts"])

    config = Swagger::Typescript::Api::Configuration.new(
      input_path: File.expand_path("../../../../fixtures/petstore.yaml", __FILE__),
      output_path: output_file.path
    )

    generator = Swagger::Typescript::Api::Generator.new(config)
    output = generator.generate

    assert_includes output, "type Pet = {"
    assert_includes output, "id: number;"
    assert_includes output, "name: string;"
    assert_includes output, "tag?: string | null;"

    assert_includes output, "type Category = {"

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

    assert_includes output, "type IPetType = {"
    assert_includes output, "type ICategoryType = {"
  ensure
    output_file.close
    output_file.unlink
  end

  def test_custom_type_imports
    output_file = Tempfile.new(["types", ".ts"])

    config = Swagger::Typescript::Api::Configuration.new(
      input_path: File.expand_path("../../../../fixtures/dds.json", __FILE__),
      output_path: output_file.path,
      custom_type_imports: {
        "Dayjs" => "import { Dayjs } from 'dayjs';"
      }
    )

    generator = Swagger::Typescript::Api::Generator.new(config)
    output = generator.generate

    assert_includes output, "import { Dayjs } from 'dayjs';"
    assert_includes output, "created_at: Dayjs;"
    assert_includes output, "last_seen: Dayjs | null;"
  ensure
    output_file.close
    output_file.unlink
  end

  def test_x_ts_type_extension
    output_file = Tempfile.new(["types", ".ts"])

    schema_json = {
      "openapi" => "3.1.0",
      "info" => {"title" => "Test", "version" => "1.0"},
      "paths" => {},
      "components" => {
        "schemas" => {
          "Event" => {
            "type" => "object",
            "properties" => {
              "name" => {"type" => "string"},
              "timestamp" => {
                "type" => "string",
                "format" => "date-time",
                "x-ts-type" => "Date"
              }
            }
          }
        }
      }
    }

    input_file = Tempfile.new(["schema", ".json"])
    input_file.write(JSON.generate(schema_json))
    input_file.close

    config = Swagger::Typescript::Api::Configuration.new(
      input_path: input_file.path,
      output_path: output_file.path,
      custom_type_imports: {
        "Date" => "// Date is a global type"
      }
    )

    generator = Swagger::Typescript::Api::Generator.new(config)
    output = generator.generate

    assert_includes output, "timestamp?: Date;"
    assert_includes output, "// Date is a global type"
  ensure
    output_file.close
    output_file.unlink
    input_file.unlink
  end
end
