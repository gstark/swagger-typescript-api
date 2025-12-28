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
            "null" => :null
          }.freeze

          def initialize(config, naming)
            @config = config
            @naming = naming
          end

          def build(schema, name = nil)
            return build_unknown if schema.nil?

            nullable = schema.respond_to?(:nullable?) && schema.nullable?
            build_type(schema, name, nullable)
          end

          private

          def build_type(schema, name, nullable = false)
            if schema.respond_to?(:one_of) && schema.one_of&.any?
              build_union(schema, name, nullable)
            elsif schema.respond_to?(:all_of) && schema.all_of&.any?
              build_intersection(schema, name, nullable)
            elsif schema.respond_to?(:any_of) && schema.any_of&.any?
              build_union(schema, name, nullable)
            elsif schema.respond_to?(:enum) && schema.enum&.any?
              build_enum(schema, name, nullable)
            elsif object_schema?(schema)
              build_interface(schema, name, nullable)
            elsif array_schema?(schema)
              build_array(schema, name, nullable)
            else
              build_primitive(schema, nullable)
            end
          end

          def build_union(schema, name, nullable = false)
            variants = schema.one_of || schema.any_of || []
            types = variants.map { |s| build(s) }

            discriminator = nil
            if schema.respond_to?(:discriminator) && schema.discriminator
              discriminator = {
                property_name: schema.discriminator.property_name,
                mapping: schema.discriminator.mapping
              }
            end

            Types::Union.new(
              name: name ? @naming.format_type_name(name) : nil,
              types: types,
              discriminator: discriminator,
              nullable: nullable
            )
          end

          def build_intersection(schema, name, nullable = false)
            types = schema.all_of.map { |s| build(s) }

            Types::Intersection.new(
              name: name ? @naming.format_type_name(name) : nil,
              types: types,
              nullable: nullable
            )
          end

          def build_enum(schema, name, nullable = false)
            values = schema.enum
            string_enum = schema.type == "string" || values.all? { |v| v.is_a?(String) }

            Types::Enum.new(
              name: name ? @naming.format_type_name(name) : nil,
              values: values,
              string_enum: string_enum,
              nullable: nullable
            )
          end

          def build_interface(schema, name, nullable = false)
            properties = {}
            required = []

            if schema.respond_to?(:properties) && schema.properties
              schema.properties.each do |prop_name, prop_schema|
                properties[prop_name] = build(prop_schema)
              end
            end

            required = schema.required.to_a if schema.respond_to?(:required) && schema.required

            additional = nil
            if schema.respond_to?(:additional_properties)
              ap = schema.additional_properties
              if ap == true
                additional = Types::Primitive.new(type: :unknown)
              elsif ap.respond_to?(:type) || ap.respond_to?(:properties)
                additional = build(ap)
              end
            end

            Types::Interface.new(
              name: name ? @naming.format_type_name(name) : nil,
              properties: properties,
              required: required,
              additional_properties: additional,
              description: schema.respond_to?(:description) ? schema.description : nil,
              nullable: nullable
            )
          end

          def build_array(schema, name = nil, nullable = false)
            item_schema = schema.items
            item_type = item_schema ? build(item_schema) : Types::Primitive.new(type: :unknown)

            Types::Array.new(
              name: name ? @naming.format_type_name(name) : nil,
              item_type: item_type,
              nullable: nullable
            )
          end

          def build_primitive(schema, nullable = false)
            type_name = schema.respond_to?(:type) ? schema.type : nil

            if type_name && OPENAPI_TO_TS.key?(type_name)
              ts_type = handle_format(schema, OPENAPI_TO_TS[type_name])
              Types::Primitive.new(type: ts_type, nullable: nullable)
            else
              Types::Primitive.new(type: :unknown, nullable: nullable)
            end
          end

          def build_unknown
            Types::Primitive.new(type: :unknown)
          end

          def handle_format(schema, base_type)
            return base_type unless schema.respond_to?(:format) && schema.format

            case schema.format
            when "date", "date-time"
              :string
            when "int32", "int64", "float", "double"
              :number
            else
              base_type
            end
          end

          def object_schema?(schema)
            return true if schema.respond_to?(:type) && schema.type == "object"
            return true if schema.respond_to?(:properties) && schema.properties&.any?

            false
          end

          def array_schema?(schema)
            return true if schema.respond_to?(:type) && schema.type == "array"
            return true if schema.respond_to?(:items) && schema.items

            false
          end
        end
      end
    end
  end
end
