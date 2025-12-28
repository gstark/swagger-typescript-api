# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        module Types
          class Interface < Base
            attr_reader :properties, :required, :additional_properties

            def initialize(properties: {}, required: [], additional_properties: nil, **options)
              super(**options)
              @properties = properties
              @required = required
              @additional_properties = additional_properties
            end

            def to_typescript
              if name
                interface_definition
              else
                inline_object
              end
            end

            def interface_definition
              body = format_body
              "interface #{name} {\n#{body}\n}"
            end

            def type_definition
              body = format_body
              "type #{name} = {\n#{body}\n}"
            end

            def inline_object
              return "{}" if properties.empty? && additional_properties.nil?

              body = format_body
              with_nullable("{\n#{body}\n}")
            end

            private

            def format_body
              lines = []

              properties.each do |prop_name, prop_type|
                if prop_type.description && !prop_type.description.empty?
                  lines << "  /** #{prop_type.description} */"
                end

                optional = required.include?(prop_name) ? "" : "?"
                formatted_name = format_property_name(prop_name)
                lines << "  #{formatted_name}#{optional}: #{prop_type.to_typescript};"
              end

              if additional_properties
                index_type = additional_properties.to_typescript
                lines << "  [key: string]: #{index_type};"
              end

              lines.join("\n")
            end

            def format_property_name(name)
              needs_quotes?(name) ? "\"#{name}\"" : name
            end

            def needs_quotes?(name)
              return true if name.match?(/^[0-9]/)
              return true if name.match?(/[^a-zA-Z0-9_$]/)
              return true if reserved_word?(name)

              false
            end

            def reserved_word?(name)
              %w[
                break case catch class const continue debugger default delete
                do else enum export extends false finally for function if import
                in instanceof new null return super switch this throw true try
                typeof var void while with yield
              ].include?(name)
            end
          end
        end
      end
    end
  end
end
