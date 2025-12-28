# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Intersection < Base
            attr_reader :types

            def initialize(types:, **options)
              super(**options)
              @types = types
            end

            def to_typescript
              return "unknown" if types.empty?

              intersection = types.map { |t| wrap_if_needed(t) }.join(" & ")
              with_nullable(intersection)
            end

            private

            def wrap_if_needed(type)
              ts = type.to_typescript
              ts.include?("|") ? "(#{ts})" : ts
            end
          end
        end
      end
    end
  end
end
