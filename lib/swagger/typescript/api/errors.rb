# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      class Error < StandardError; end

      class ParseError < Error; end

      class ValidationError < Error; end

      class UnsupportedSchemaError < Error; end
    end
  end
end
