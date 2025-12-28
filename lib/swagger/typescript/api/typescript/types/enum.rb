# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Enum < Base
            attr_reader :values, :string_enum

            def initialize(values:, string_enum: true, **options)
              super(**options)
              @values = values
              @string_enum = string_enum
            end

            def to_typescript
              if name
                enum_definition
              else
                union_type
              end
            end

            def enum_definition
              members = values.map { |v| enum_member(v) }.join("\n  ")
              "enum #{name} {\n  #{members}\n}"
            end

            def union_type
              union = values.map { |v| format_value(v) }.join(" | ")
              with_nullable(union)
            end

            private

            def enum_member(value)
              key = format_key(value)
              formatted = format_value(value)
              "#{key} = #{formatted},"
            end

            def format_key(value)
              key = value.to_s
                .gsub(/[^a-zA-Z0-9_]/, "_")
                .gsub(/^(\d)/, '_\1')

              key = "VALUE_#{key}" if key.empty?
              key.upcase
            end

            def format_value(value)
              case value
              when String
                "\"#{value}\""
              when Numeric
                value.to_s
              when TrueClass, FalseClass
                value.to_s
              else
                "\"#{value}\""
              end
            end
          end
        end
      end
    end
  end
end
