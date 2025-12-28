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

        def generate
          config = Configuration.new(
            input_path: options[:input],
            output_path: options[:output],
            type_prefix: options[:prefix] || "",
            type_suffix: options[:suffix] || "",
            export_types: !options[:no_export]
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
      end
    end
  end
end
