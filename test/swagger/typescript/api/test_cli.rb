# frozen_string_literal: true

require "test_helper"

class Swagger::Typescript::Api::TestCLI < Minitest::Test
  def test_parse_imports_with_single_import
    cli = Swagger::Typescript::Api::CLI.new

    result = cli.send(:parse_imports, [["Dayjs=import { Dayjs } from 'dayjs';"]])

    assert_equal({"Dayjs" => "import { Dayjs } from 'dayjs';"}, result)
  end

  def test_parse_imports_with_multiple_imports
    cli = Swagger::Typescript::Api::CLI.new

    result = cli.send(:parse_imports, [
      ["Dayjs=import { Dayjs } from 'dayjs';"],
      ["Decimal=import { Decimal } from 'decimal.js';"]
    ])

    expected = {
      "Dayjs" => "import { Dayjs } from 'dayjs';",
      "Decimal" => "import { Decimal } from 'decimal.js';"
    }
    assert_equal expected, result
  end

  def test_parse_imports_with_nil
    cli = Swagger::Typescript::Api::CLI.new

    result = cli.send(:parse_imports, nil)

    assert_equal({}, result)
  end

  def test_parse_imports_with_empty_array
    cli = Swagger::Typescript::Api::CLI.new

    result = cli.send(:parse_imports, [])

    assert_equal({}, result)
  end

  def test_parse_imports_strips_whitespace
    cli = Swagger::Typescript::Api::CLI.new

    result = cli.send(:parse_imports, [["  Dayjs  =  import { Dayjs } from 'dayjs';  "]])

    assert_equal({"Dayjs" => "import { Dayjs } from 'dayjs';"}, result)
  end

  def test_parse_imports_handles_equals_in_statement
    cli = Swagger::Typescript::Api::CLI.new

    result = cli.send(:parse_imports, [["Custom=const x = require('x');"]])

    assert_equal({"Custom" => "const x = require('x');"}, result)
  end
end
