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
          :strict_validation,
          :type_style,
          :custom_type_imports

        def initialize(
          input_path: nil,
          output_path: nil,
          type_prefix: "",
          type_suffix: "",
          export_types: true,
          strict_nullable: true,
          strict_validation: true,
          type_style: :type,
          custom_type_imports: {}
        )
          @input_path = input_path
          @output_path = output_path
          @type_prefix = type_prefix
          @type_suffix = type_suffix
          @export_types = export_types
          @strict_nullable = strict_nullable
          @strict_validation = strict_validation
          @type_style = type_style
          @custom_type_imports = custom_type_imports
        end

        def use_interface?
          type_style == :interface
        end

        def import_for(type_name)
          custom_type_imports[type_name]
        end
      end
    end
  end
end
