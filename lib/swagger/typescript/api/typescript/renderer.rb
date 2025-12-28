# frozen_string_literal: true

require "erb"

module Swagger
  module Typescript
    module Api
      module TypeScript
        class Renderer
          DEFAULT_TEMPLATE_DIR = File.expand_path("../../../../../templates", __dir__)

          def initialize(template_dir: nil)
            @template_dir = template_dir || DEFAULT_TEMPLATE_DIR
          end

          def render(types, config)
            template_path = File.join(@template_dir, "types.ts.erb")
            template = ERB.new(File.read(template_path), trim_mode: "-")

            binding_context = create_binding(types, config)
            template.result(binding_context)
          end

          private

          def create_binding(types, config)
            export_keyword = config.export_types ? "export " : ""

            binding.tap do |b|
              b.local_variable_set(:types, types)
              b.local_variable_set(:config, config)
              b.local_variable_set(:export_keyword, export_keyword)
            end
          end
        end
      end
    end
  end
end
