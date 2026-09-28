require "json"
require "net/http"
require "rubygems/package"
require "stringio"
require "zlib"

# Generates the data behind AppicaUI::Icon from the published @appica/icons-react package (MIT):
#
#   bundle exec rake "ui_components:icons:sync[1.1.0]"
#
# Every icon in the package is `createIcon("Name", '<inner svg>', { fill: "none", stroke: … })` in
# dist/icons/<category>/<name>.js. We keep the inner markup and the svg options, one JSON file per
# category plus an index (name => category) in app/components/appica_ui/icon/icons/. No Node needed.
namespace :ui_components do
  namespace :icons do
    desc "Download @appica/icons-react and regenerate app/components/appica_ui/icon/icons/*.json"
    task :sync, [ :version ] do |_task, args|
      version = args[:version] || "1.1.0"
      target = File.expand_path("../../app/components/appica_ui/icon/icons", __dir__)
      outline = { "fill" => "none", "stroke" => "currentColor", "stroke_width" => "1.5", "stroke_linecap" => "round", "stroke_linejoin" => "round" }

      url = URI("https://registry.npmjs.org/@appica/icons-react/-/icons-react-#{version}.tgz")
      puts "Downloading #{url}"
      response = Net::HTTP.get_response(url)
      raise "Download failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      categories = Hash.new { |hash, key| hash[key] = {} }
      license = nil

      Gem::Package::TarReader.new(Zlib::GzipReader.new(StringIO.new(response.body))) do |tar|
        tar.each do |entry|
          license = entry.read if entry.full_name == "package/LICENSE"
          match = entry.full_name.match(%r{\Apackage/dist/icons/([^/]+)/([^/]+)\.js\z})
          next unless match

          source = entry.read
          call = source.match(/createIcon\("[^"]+",\s*'((?:[^'\\]|\\.)*)'(?:,\s*\{([^}]*)\})?\)/m)
          raise "Unexpected icon source in #{entry.full_name}" unless call

          options = call[2].to_s.scan(/(\w+):\s*"([^"]*)"/).to_h { |key, value| [ key.gsub(/([A-Z])/) { "_#{$1.downcase}" }, value ] }
          icon = { "content" => call[1].gsub("\\'", "'") }
          icon["view_box"] = options.delete("view_box") if options.key?("view_box")
          if options == outline
            icon["outline"] = true
          elsif options.any?
            icon["attrs"] = options
          end
          categories[match[1]][match[2]] = icon
        end
      end

      FileUtils.rm_rf(target)
      FileUtils.mkdir_p(target)
      index = {}
      categories.sort.each do |category, icons|
        File.write(File.join(target, "#{category}.json"), JSON.generate(icons.sort.to_h))
        icons.each_key { |name| index[name] = category }
      end
      File.write(File.join(target, "index.json"), JSON.generate(index.sort.to_h))
      File.write(File.join(target, "LICENSE-appica-icons"), "@appica/icons-react #{version}\nhttps://appica.dev/ui/icons\n\n#{license}")

      puts "Wrote #{index.size} icons in #{categories.size} categories to #{target}"
    end
  end
end
