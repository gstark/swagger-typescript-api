# frozen_string_literal: true

require_relative "lib/swagger/typescript/api/version"

Gem::Specification.new do |spec|
  spec.name = "swagger-typescript-api"
  spec.version = Swagger::Typescript::Api::VERSION
  spec.authors = ["Gavin Stark"]
  spec.email = ["gavin@gstark.com"]

  spec.summary = "Generate TypeScript types from OpenAPI 3.0 specifications"
  spec.description = "A Ruby gem that reads OpenAPI 3.0 specifications and generates TypeScript type definitions including interfaces, enums, unions, and intersections."
  spec.homepage = "https://github.com/gstark/swagger-typescript-api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "openapi3_parser", "~> 0.10"
  spec.add_dependency "thor", "~> 1.3"
end
