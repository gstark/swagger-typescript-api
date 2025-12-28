# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        class Naming
          def initialize(config)
            @config = config
          end

          def format_type_name(name)
            formatted = pascalize(sanitize(name))
            "#{@config.type_prefix}#{formatted}#{@config.type_suffix}"
          end

          def format_property_name(name)
            needs_quotes?(name) ? "\"#{name}\"" : name
          end

          private

          def pascalize(string)
            string
              .gsub(/[^a-zA-Z0-9_]/, " ")
              .split(/[\s_]+/)
              .map(&:capitalize)
              .join
          end

          def sanitize(name)
            name.to_s.gsub(/[^a-zA-Z0-9_\s]/, "_")
          end

          def needs_quotes?(name)
            return true if name.match?(/^[0-9]/)
            return true if name.match?(/[^a-zA-Z0-9_$]/)

            false
          end
        end
      end
    end
  end
end
