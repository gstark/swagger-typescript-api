# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      module TypeScript
        class TypeBuilder
          OPENAPI_TO_TS = {
            "string" => :string,
            "number" => :number,
            "integer" => :number,
            "boolean" => :boolean,
            "null" => :null,
            "object" => :object
          }.freeze

          attr_reader :used_custom_types

          def initialize(config, naming, document = nil)
            @config = config
            @naming = naming
            @document = document
            @used_custom_types = Set.new
          end

          def build(schema, name = nil)
            return build_unknown if schema.nil?

            if schema.is_a?(Hash) && schema["$ref"]
              return build_reference(schema)
            end

            # Check for x-ts-type extension first
            if schema.is_a?(Hash) && schema["x-ts-type"]
              return build_custom_type(schema)
            end

            nullable = extract_nullable(schema)
            build_type(schema, name, nullable)
          end

          private

          def build_custom_type(schema)
            type_name = schema["x-ts-type"]
            nullable = extract_nullable(schema)
            description = schema["description"]

            @used_custom_types << type_name

            Types::Custom.new(
              type_name: type_name,
              nullable: nullable,
              description: description
            )
          end

          def build_reference(schema)
            ref = schema["$ref"]
            type_name = extract_type_name_from_ref(ref)

            return build_unknown unless type_name

            nullable = schema["nullable"] == true
            description = schema["description"]

            # Look up the referenced schema's description if not provided
            if description.nil? || description.empty?
              description = lookup_ref_description(ref)
            end

            Types::Reference.new(
              ref_name: @naming.format_type_name(type_name),
              nullable: nullable,
              description: description
            )
          end

          def lookup_ref_description(ref)
            return nil unless @document && ref.is_a?(String)

            if ref.start_with?("#/components/schemas/")
              schema_name = ref.split("/").last
              target_schema = @document.schemas[schema_name]
              target_schema&.dig("description")
            end
          end

          def extract_type_name_from_ref(ref)
            return nil unless ref.is_a?(String)

            if ref.start_with?("#/components/schemas/")
              ref.split("/").last
            end
          end

          def extract_nullable(schema)
            return false unless schema.is_a?(Hash)

            return true if schema["nullable"] == true

            type = schema["type"]
            if type.is_a?(Array)
              type.include?("null")
            else
              false
            end
          end

          def normalize_type(schema)
            type = schema["type"]
            if type.is_a?(Array)
              type.reject { |t| t == "null" }.first
            else
              type
            end
          end

          def build_type(schema, name, nullable = false)
            return build_unknown unless schema.is_a?(Hash)

            if schema["oneOf"]&.any?
              build_union(schema, "oneOf", name, nullable)
            elsif schema["allOf"]&.any?
              build_intersection(schema, name, nullable)
            elsif schema["anyOf"]&.any?
              build_union(schema, "anyOf", name, nullable)
            elsif schema["enum"]&.any?
              build_enum(schema, name, nullable)
            elsif object_schema?(schema)
              build_interface(schema, name, nullable)
            elsif array_schema?(schema)
              build_array(schema, name, nullable)
            else
              build_primitive(schema, nullable)
            end
          end

          def build_union(schema, key, name, nullable = false)
            variants = schema[key] || []
            types = variants.map { |s| build(s) }
            description = schema["description"]

            discriminator = nil
            if schema["discriminator"]
              discriminator = {
                property_name: schema["discriminator"]["propertyName"],
                mapping: schema["discriminator"]["mapping"]
              }
            end

            Types::Union.new(
              name: name ? @naming.format_type_name(name) : nil,
              types: types,
              discriminator: discriminator,
              nullable: nullable,
              description: description
            )
          end

          def build_intersection(schema, name, nullable = false)
            types = (schema["allOf"] || []).map { |s| build(s) }
            description = schema["description"]

            Types::Intersection.new(
              name: name ? @naming.format_type_name(name) : nil,
              types: types,
              nullable: nullable,
              description: description
            )
          end

          def build_enum(schema, name, nullable = false)
            values = schema["enum"] || []
            type = normalize_type(schema)
            string_enum = type == "string" || values.all? { |v| v.is_a?(String) }
            description = schema["description"]

            Types::Enum.new(
              name: name ? @naming.format_type_name(name) : nil,
              values: values,
              string_enum: string_enum,
              nullable: nullable,
              description: description
            )
          end

          def build_interface(schema, name, nullable = false)
            properties = {}
            required = schema["required"] || []

            (schema["properties"] || {}).each do |prop_name, prop_schema|
              properties[prop_name] = build(prop_schema)
            end

            additional = nil
            ap = schema["additionalProperties"]
            if ap == true
              additional = Types::Primitive.new(type: :unknown)
            elsif ap.is_a?(Hash)
              additional = build(ap)
            end

            Types::Interface.new(
              name: name ? @naming.format_type_name(name) : nil,
              properties: properties,
              required: required,
              additional_properties: additional,
              description: schema["description"],
              nullable: nullable
            )
          end

          def build_array(schema, name = nil, nullable = false)
            item_schema = schema["items"]
            item_type = item_schema ? build(item_schema) : Types::Primitive.new(type: :unknown)
            description = schema["description"]

            Types::Array.new(
              name: name ? @naming.format_type_name(name) : nil,
              item_type: item_type,
              nullable: nullable,
              description: description
            )
          end

          def build_primitive(schema, nullable = false)
            type_name = normalize_type(schema)
            description = schema["description"]

            if type_name && OPENAPI_TO_TS.key?(type_name)
              ts_type = handle_format(schema, OPENAPI_TO_TS[type_name])
              Types::Primitive.new(type: ts_type, nullable: nullable, description: description)
            elsif type_name && !type_name.empty?
              # Treat unrecognized type names as custom types
              @used_custom_types << type_name
              Types::Custom.new(type_name: type_name, nullable: nullable, description: description)
            else
              Types::Primitive.new(type: :unknown, nullable: nullable, description: description)
            end
          end

          def build_unknown
            Types::Primitive.new(type: :unknown)
          end

          def handle_format(schema, base_type)
            format = schema["format"]
            return base_type unless format

            case format
            when "date", "date-time"
              :string
            when "int32", "int64", "float", "double"
              :number
            else
              base_type
            end
          end

          def object_schema?(schema)
            type = normalize_type(schema)
            return true if type == "object"
            return true if schema["properties"]&.any?

            false
          end

          def array_schema?(schema)
            type = normalize_type(schema)
            return true if type == "array"
            return true if schema.key?("items")

            false
          end
        end
      end
    end
  end
end
