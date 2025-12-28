# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Custom < Base
            attr_reader :type_name

            def initialize(type_name:, **options)
              super(**options)
              @type_name = type_name
            end

            def to_typescript
              with_nullable(type_name)
            end
          end
        end
      end
    end
  end
end
