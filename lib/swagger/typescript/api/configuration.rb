# frozen_string_literal: true

module Swagger
  module Typescript
    module Api
      class Configuration
        attr_accessor :input_path,
          :output_path,
          :type_prefix,
          :type_suffix,
          :export_types,
          :strict_nullable,
          :strict_validation

        def initialize(
          input_path: nil,
          output_path: nil,
          type_prefix: "",
          type_suffix: "",
          export_types: true,
          strict_nullable: true,
          strict_validation: true
        )
          @input_path = input_path
          @output_path = output_path
          @type_prefix = type_prefix
          @type_suffix = type_suffix
          @export_types = export_types
          @strict_nullable = strict_nullable
          @strict_validation = strict_validation
        end
      end
    end
  end
end
