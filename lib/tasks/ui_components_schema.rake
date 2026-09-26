# Regenerates the machine-readable component descriptions (for LLMs / MCP servers):
#
#   bin/rails ui_components:schema          # from test/dummy (or: bin/rails app:ui_components:schema at the root)
#
# Writes app/components/<kit>/<folder>/<folder>.schema.json for every component folder and the
# index app/components/schema.json - see UiComponents::Schema. Run it after changing props,
# class comments or Lookbook previews (test/components/schema_test.rb checks they're current).
namespace :ui_components do
  desc "Generate <component>.schema.json files and app/components/schema.json"
  task schema: :environment do
    paths = UiComponents::Schema.generate!
    root = Pathname.new(File.expand_path("../..", __dir__))
    puts "Wrote #{paths.size} files:"
    paths.each { |path| puts "  #{Pathname.new(path).relative_path_from(root)}" }
  end
end
