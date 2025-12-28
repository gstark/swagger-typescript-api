# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Reference < Base
            attr_reader :ref_name

            def initialize(ref_name:, **options)
              super(**options)
              @ref_name = ref_name
            end

            def to_typescript
              with_nullable(ref_name)
            end
          end
        end
      end
    end
  end
end
