# frozen_string_literal: true

require "fileutils"

require "swagger/typescript/api/version"

require "swagger/typescript/api/errors"

require "swagger/typescript/api/configuration"

require "swagger/typescript/api/openapi/document"

require "swagger/typescript/api/typescript/types/base"
require "swagger/typescript/api/typescript/types/array"
require "swagger/typescript/api/typescript/types/custom"
require "swagger/typescript/api/typescript/types/enum"
require "swagger/typescript/api/typescript/types/interface"
require "swagger/typescript/api/typescript/types/intersection"
require "swagger/typescript/api/typescript/types/literal"
require "swagger/typescript/api/typescript/types/primitive"
require "swagger/typescript/api/typescript/types/reference"
require "swagger/typescript/api/typescript/types/union"

require "swagger/typescript/api/typescript/naming"
require "swagger/typescript/api/typescript/renderer"
require "swagger/typescript/api/typescript/type_builder"

require "swagger/typescript/api/generator"

require "swagger/typescript/api/cli"

module Swagger
  module Typescript
    module Api
    end
  end
end
