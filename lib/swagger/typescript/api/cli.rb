# frozen_string_literal: true

require "thor"

module Swagger
  module Typescript
    module Api
      class CLI < Thor
        desc "generate", "Generate TypeScript types from OpenAPI spec"
        option :input, aliases: "-i", required: true, desc: "Path or URL to OpenAPI spec"
        option :output, aliases: "-o", required: true, desc: "Output file path"
        option :prefix, desc: "Type name prefix (e.g., 'I' for IUser)"
        option :suffix, desc: "Type name suffix (e.g., 'Type' for UserType)"
        option :no_export, type: :boolean, desc: "Don't export types"
        option :import, type: :array, repeatable: true, desc: "Custom type import (TYPE=STATEMENT)"

        def generate
          config = Configuration.new(
            input_path: options[:input],
            output_path: options[:output],
            type_prefix: options[:prefix] || "",
            type_suffix: options[:suffix] || "",
            export_types: !options[:no_export],
            custom_type_imports: parse_imports(options[:import])
          )

          generator = Generator.new(config)
          generator.generate

          say "Types generated successfully to #{options[:output]}", :green
        rescue Error => e
          say "Error: #{e.message}", :red
          exit 1
        end

        desc "version", "Print version"
        def version
          say VERSION
        end

        def self.exit_on_failure?
          true
        end

        private

        def parse_imports(import_options)
          return {} if import_options.nil? || import_options.empty?

          import_options.flatten.each_with_object({}) do |import, hash|
            type_name, statement = import.split("=", 2)
            if type_name && statement
              hash[type_name.strip] = statement.strip
            end
          end
        end
      end
    end
  end
end
