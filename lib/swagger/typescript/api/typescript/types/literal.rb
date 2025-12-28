# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Literal < Base
            attr_reader :value

            def initialize(value:, **options)
              super(**options)
              @value = value
            end

            def to_typescript
              literal = case value
              when String
                "\"#{escape_string(value)}\""
              when TrueClass, FalseClass
                value.to_s
              when Numeric
                value.to_s
              when NilClass
                "null"
              else
                value.to_s
              end

              with_nullable(literal)
            end

            private

            def escape_string(str)
              str.gsub("\\", "\\\\").gsub('"', '\\"').gsub("\n", "\\n")
            end
          end
        end
      end
    end
  end
end
