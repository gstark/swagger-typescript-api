# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Primitive < Base
            VALID_TYPES = %i[string number boolean null any unknown void never].freeze

            attr_reader :type

            def initialize(type:, **options)
              super(**options)
              @type = type.to_sym
              validate_type!
            end

            def to_typescript
              with_nullable(type.to_s)
            end

            private

            def validate_type!
              return if VALID_TYPES.include?(type)

              raise ArgumentError, "Invalid primitive type: #{type}. Valid types: #{VALID_TYPES.join(", ")}"
            end
          end
        end
      end
    end
  end
end
