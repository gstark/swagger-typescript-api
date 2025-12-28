# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Base
            attr_reader :name, :description, :nullable

            def initialize(name: nil, description: nil, nullable: false)
              @name = name
              @description = description
              @nullable = nullable
            end

            def to_typescript
              raise NotImplementedError, "Subclasses must implement #to_typescript"
            end

            def with_nullable(type_string)
              nullable ? "#{type_string} | null" : type_string
            end

            def inline?
              name.nil?
            end
          end
        end
      end
    end
  end
end
