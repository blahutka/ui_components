require_relative "lib/ui_components/version"

Gem::Specification.new do |spec|
  spec.name        = "ui_components"
  spec.version     = UiComponents::VERSION
  spec.authors     = [ "blahutka" ]
  spec.summary     = "Appica-styled UI components for Rails, built with Phlex, Tailwind v4 and Stimulus."
  spec.license     = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2"
  spec.add_dependency "phlex-rails", "~> 2.1"
  spec.add_dependency "tailwind_merge", ">= 0.13"
  spec.add_dependency "dry-initializer", "~> 3.2"
  spec.add_dependency "importmap-rails", ">= 1.2"
  spec.add_dependency "stimulus-rails", ">= 1.3"
end
