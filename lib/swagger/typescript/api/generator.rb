# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      class Generator
        attr_reader :config

        def initialize(config)
          @config = config
        end

        def generate
          validate_config!
          document = load_document
          validate_document!(document)
          types, imports = build_types(document)
          output = render(types, imports)
          write_output(output)
          output
        end

        private

        def validate_config!
          raise ValidationError, "Input path is required" if config.input_path.nil? || config.input_path.empty?
          raise ValidationError, "Output path is required" if config.output_path.nil? || config.output_path.empty?
        end

        def load_document
          OpenAPI::Document.new(config.input_path)
        end

        def validate_document!(document)
          return if document.valid?
          return unless config.strict_validation

          error_messages = document.errors.map(&:message).join(", ")
          raise ValidationError, "Invalid OpenAPI document: #{error_messages}"
        end

        def build_types(document)
          naming = TypeScript::Naming.new(config)
          type_builder = TypeScript::TypeBuilder.new(config, naming, document)

          types = document.schemas.map do |name, schema|
            type_builder.build(schema, name)
          end

          imports = collect_imports(type_builder.used_custom_types)
          [types, imports]
        end

        def collect_imports(used_custom_types)
          imports = []
          used_custom_types.each do |type_name|
            import_statement = config.import_for(type_name)
            imports << import_statement if import_statement
          end
          imports.uniq.sort
        end

        def render(types, imports)
          renderer = TypeScript::Renderer.new
          renderer.render(types, imports, config)
        end

        def write_output(output)
          output_dir = File.dirname(config.output_path)
          FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
          File.write(config.output_path, output)
        end
      end
    end
  end
end
