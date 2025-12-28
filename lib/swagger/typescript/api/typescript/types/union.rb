# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Union < Base
            attr_reader :types, :discriminator

            def initialize(types:, discriminator: nil, **options)
              super(**options)
              @types = types
              @discriminator = discriminator
            end

            def to_typescript
              return "never" if types.empty?

              union = types.map(&:to_typescript).join(" | ")
              with_nullable(union)
            end
          end
        end
      end
    end
  end
end
