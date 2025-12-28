# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Array < Base
            attr_reader :item_type

            def initialize(item_type:, **options)
              super(**options)
              @item_type = item_type
            end

            def to_typescript
              item_ts = item_type.to_typescript

              array_type = if needs_parentheses?(item_ts)
                "(#{item_ts})[]"
              else
                "#{item_ts}[]"
              end

              with_nullable(array_type)
            end

            private

            def needs_parentheses?(type_string)
              type_string.include?("|") || type_string.include?("&")
            end
          end
        end
      end
    end
  end
end
