# frozen_string_literal: true

require "date"
require "json"
require "net/http"
require "uri"
require "yaml"

module Swagger
  module Typescript
    module Api
      module OpenAPI
        class Document
          attr_reader :raw_document

          def initialize(path_or_url)
            @raw_document = load_document(path_or_url)
          end

          def schemas
            @raw_document.dig("components", "schemas") || {}
          end

          def valid?
            @raw_document.is_a?(Hash) && @raw_document.key?("openapi")
          end

          def errors
            []
          end

          def resolve_ref(ref)
            return nil unless ref.is_a?(String) && ref.start_with?("#/")

            parts = ref.sub("#/", "").split("/")
            parts.reduce(@raw_document) do |doc, part|
              doc&.dig(part)
            end
          end

          def ref_to_type_name(ref)
            return nil unless ref.is_a?(String) && ref.start_with?("#/components/schemas/")

            ref.split("/").last
          end

          private

          def load_document(path_or_url)
            content = fetch_content(path_or_url)
            parse_content(content, path_or_url)
          rescue => e
            raise ParseError, "Failed to parse OpenAPI document: #{e.message}"
          end

          def fetch_content(path_or_url)
            if url?(path_or_url)
              fetch_url(path_or_url)
            else
              File.read(path_or_url)
            end
          end

          def fetch_url(url)
            uri = URI.parse(url)
            response = Net::HTTP.get_response(uri)

            raise ParseError, "HTTP #{response.code}: #{response.message}" unless response.is_a?(Net::HTTPSuccess)

            response.body
          end

          def parse_content(content, path)
            if path.end_with?(".json") || content.strip.start_with?("{")
              JSON.parse(content)
            else
              YAML.safe_load(content, permitted_classes: [Date, Time])
            end
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
