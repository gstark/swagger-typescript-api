# frozen_string_literal: true

require "openapi3_parser"
require "uri"

module Swagger
  module Typescript
    module Api
      module OpenAPI
        class Document
          attr_reader :document

          def initialize(path_or_url)
            @document = load_document(path_or_url)
          end

          def schemas
            document.components&.schemas&.to_h || {}
          end

          def valid?
            document.valid?
          end

          def errors
            document.errors
          end

          private

          def load_document(path_or_url)
            if url?(path_or_url)
              Openapi3Parser.load_url(path_or_url)
            else
              Openapi3Parser.load_file(path_or_url)
            end
          rescue => e
            raise ParseError, "Failed to parse OpenAPI document: #{e.message}"
          end

          def url?(string)
            uri = URI.parse(string)
            uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          rescue URI::InvalidURIError
            false
          end
        end
      end
    end
  end
end
