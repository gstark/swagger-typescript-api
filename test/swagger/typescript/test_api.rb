# frozen_string_literal: true

require "test_helper"

class Swagger::Typescript::TestApi < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Swagger::Typescript::Api::VERSION
  end
end
