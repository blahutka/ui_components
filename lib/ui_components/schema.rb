require "json"

module UiComponents
  # Machine-readable descriptions of the components, for LLMs and MCP servers.
  #
  #   bin/rails ui_components:schema     # (from test/dummy) writes the files below
  #
  # Nothing is written by hand - everything comes from what the components already declare:
  #
  # - props: the `prop` declarations (UI::Props) - names, required or not, defaults, the
  #   choices of `one_of`, `desc:`;
  # - description: the comment above each class;
  # - nesting: which part renders inside which root, recorded while rendering every Lookbook
  #   scenario (each part `consume`s its parent);
  # - examples: every Lookbook scenario's source and notes - real, working calls.
  #
  # One `<folder>.schema.json` per component folder (a compound component and all its parts),
  # plus `app/components/schema.json`, the index an agent reads first.
  module Schema
    ROOT = Pathname.new(File.expand_path("../../app/components", __dir__))
    KITS = { "ui" => "UI", "blocks" => "Blocks" }.freeze
    INDEX = ROOT.join("schema.json")
    SKIPPED_FILES = %w[ base.rb props.rb localized.rb number_format.rb smil.rb view_annotation.rb base_preview.rb ].freeze

    class << self
      # Nesting recorder: UI::Base#consume reports (parent class, part class) while recording
      def recording?
        Thread.current[:ui_components_schema_parts]
      end

      def record_part(parent, part)
        parts = Thread.current[:ui_components_schema_parts]
        (parts[parent] ||= Set.new) << part
      end

      def record
        Thread.current[:ui_components_schema_parts] = {}
        yield
        Thread.current[:ui_components_schema_parts]
      ensure
        Thread.current[:ui_components_schema_parts] = nil
      end

      # A component class's props as a JSON-Schema-shaped Hash
      def props_schema(klass)
        options = klass.dry_initializer.options
        properties = options.to_h { |option| [ option.source.to_s, property(klass, option) ] }
        required = options.reject(&:optional).map { |option| option.source.to_s }

        { "type" => "object", "properties" => properties, "required" => required.presence,
          "additionalProperties" => true }.compact
      end

      # Writes every <folder>.schema.json and the index; returns the written paths
      def generate!
        documents.map { |path, document| write(path, document) }
      end

      # { path => Hash } for every schema file, without writing
      def documents
        parts = record_nesting
        folders = components.group_by { |component| component[:folder] }
        files = folders.sort.to_h do |folder, members|
          [ folder.join("#{folder.basename}.schema.json"), folder_document(folder, members, parts) ]
        end
        files.merge(INDEX => index_document(files))
      end

      def write(path, document)
        File.write(path, "#{JSON.pretty_generate(document)}\n")
        path
      end

      private
        # Every Phlex component class, with its kit and folder
        def components
          @components ||= KITS.flat_map do |dir, kit|
            Dir[ROOT.join(dir, "**/*.rb")].sort.filter_map do |file|
              next if file.end_with?("_preview.rb") || SKIPPED_FILES.include?(File.basename(file)) || file.include?("/support/")

              klass = component_class(kit, file)
              { klass:, kit:, file: Pathname.new(file), folder: Pathname.new(File.dirname(file)) } if klass
            end
          end
        end

        def component_class(kit, file)
          name = Rails.autoloaders.main.inflector.camelize(File.basename(file, ".rb"), file)
          klass = "#{kit}::#{name}".safe_constantize
          klass if klass.is_a?(Class) && klass < UI::Base
        end

        # Renders every Lookbook scenario once, recording parent → parts
        def record_nesting
          return {} unless defined?(::Lookbook)

          record do
            ::Lookbook.previews.each do |preview|
              scenarios(preview).each { |scenario| render_scenario(preview.preview_class, scenario.name) }
            end
          end
        end

        def render_scenario(preview_class, name)
          result = preview_class.new.public_send(name)
          component = result.is_a?(Hash) ? result[:component] : nil
          ActionController::Base.renderer.render(component, layout: false) if component
        rescue StandardError, NotImplementedError
          nil # a scenario that needs a real request - its nesting is recorded by the others
        end

        def folder_document(folder, members, parts)
          root = members.find { |member| member[:file].basename(".rb").to_s == folder.basename.to_s } || members.first

          {
            "name" => root[:klass].name.demodulize,
            "kit" => root[:kit],
            "description" => description(root[:file], root[:klass]),
            "usage" => "Call the kit method inside a Phlex view that includes #{root[:kit]} " \
              "(e.g. `#{root[:klass].name.demodulize}(**props) { … }`); unknown keywords (class:, id:, data:, aria_*) " \
              "go to the root element.",
            "docs" => docs_page(folder),
            "appica" => appica_url(folder),
            "components" => members.to_h { |member| [ member[:klass].name.demodulize, component_entry(member, parts, root) ] },
            "examples" => examples(folder),
            "example_helpers" => example_helpers(folder)
          }.compact
        end

        def component_entry(member, parts, root)
          klass = member[:klass]
          parents = parts.select { |_parent, children| children.include?(klass) }.keys
          {
            "constant" => klass.name,
            "description" => (description(member[:file], klass) unless member.equal?(root)),
            "props" => props_schema(klass),
            "parts" => parts.fetch(klass, []).map(&:name).sort.presence,
            "render_inside" => parents.map(&:name).sort.presence
          }.compact
        end

        # The comment block right above `class …`, without Lookbook tags
        def description(file, klass)
          lines = File.readlines(file)
          index = lines.index { |line| line.match?(/^\s*class #{Regexp.escape(klass.name)}\b/) }
          return unless index

          comment = lines[0...index].reverse.take_while { |line| line.strip.start_with?("#") }.reverse
          text = comment.map { |line| line.strip.delete_prefix("#").delete_prefix(" ").rstrip }.reject { |line| line.start_with?("@") }
          unwrap(text).presence
        end

        # Joins the hard-wrapped lines of each prose paragraph; indented (code) lines stay as they are
        def unwrap(lines)
          lines.chunk_while { |a, b| !a.empty? && !b.empty? && !a.start_with?(" ") && !b.start_with?(" ") }
            .map { |chunk| chunk.first.start_with?(" ") ? chunk.join("\n") : chunk.join(" ") }
            .join("\n").gsub(/\n{3,}/, "\n\n").strip
        end

        def docs_page(folder)
          page = Dir[ROOT.join("../../docs/lookbook/**/#{folder.basename}.md.erb")].first
          Pathname.new(page).cleanpath.relative_path_from(ROOT.join("../..").cleanpath).to_s if page
        end

        def appica_url(folder)
          page = docs_page(folder)
          File.read(ROOT.join("../..", page))[%r{https://appica\.dev/ui/components/react/[\w-]+}] if page
        end

        # Every Lookbook scenario of the folder's previews: its label, notes and source
        def examples(folder)
          return unless defined?(::Lookbook)

          previews = ::Lookbook.previews.select { |preview| preview_file(preview.preview_class)&.then { |file| File.dirname(file) == folder.to_s } }
          previews.flat_map do |preview|
            scenarios(preview).map do |scenario|
              { "name" => scenario.label.to_s, "notes" => scenario.notes.to_s.strip.presence, "code" => scenario.source.to_s.strip }.compact
            end
          end.presence
        end

        # The preview constants the examples use (FRUIT_ITEMS = proc do … end), so the code is complete
        def example_helpers(folder)
          examples = examples(folder)
          return unless examples

          constants = Dir[folder.join("*_preview.rb")].flat_map { |file| preview_constants(File.readlines(file)) }.to_h
          code = examples.map { |example| example["code"] }.join("\n")
          used = {}
          # Transitively: FRUIT_ITEMS uses FRUITS
          loop do
            found = constants.reject { |name, _| used.key?(name) }.select { |name, _| code.match?(/\b#{name}\b/) }
            break if found.empty?

            used.merge!(found)
            code = found.values.join("\n")
          end
          constants.slice(*used.keys).presence
        end

        # CONSTANT = … at class level, up to the blank line that ends it
        def preview_constants(lines)
          lines.each_with_index.filter_map do |line, index|
            next unless (match = line.match(/^(\s+)([A-Z][A-Z0-9_]+) = /))

            body = lines[index..].take_while { |candidate| !candidate.strip.empty? }
            body = body.take_while.with_index { |candidate, i| i.zero? || !candidate.match?(/^#{match[1]}(#|def |[A-Z][A-Z0-9_]+ = )/) }
            [ match[2], body.map { |candidate| candidate.delete_prefix(match[1]) }.join.rstrip ]
          end
        end

        # A preview's scenarios, with @!group groups flattened into their members
        def scenarios(preview)
          preview.scenarios.flat_map { |entry| entry.respond_to?(:source) ? [ entry ] : entry.scenarios.to_a }
        end

        def preview_file(preview_class)
          Object.const_source_location(preview_class.name)&.first
        end

        def index_document(files)
          components = files.map do |path, document|
            {
              "name" => document["name"],
              "kit" => document["kit"],
              "summary" => document["description"].to_s.split("\n\n").first.to_s.split(/(?<=[.!?])\s/).first,
              "parts" => document["components"].keys - [ document["name"] ],
              "schema" => path.relative_path_from(ROOT).to_s
            }
          end

          {
            "description" => "Phlex UI components (a port of Appica UI) with Tailwind v4 classes and Stimulus controllers. " \
              "UI holds the primitives, Blocks the compositions. Each entry's `schema` file lists the props, the compound " \
              "parts (with where each renders), and working examples.",
            "kits" => {
              "UI" => "include UI in a Phlex view, then call Button(...), Select(...) { … }",
              "Blocks" => "include Blocks (and UI) to use compositions like ReviewSummary(...)"
            },
            "theme" => "Colors come from CSS variables (ui/theme.css). Override them after importing ui/index.css; " \
              "never replace theme.css.",
            "components" => components
          }
        end
    end

    # The props of a component, for UI::Props.to_schema
    def self.property(klass, option)
      schema = option.type.respond_to?(:schema) ? option.type.schema.dup : {}
      desc = option.instance_variable_get(:@desc)
      schema["description"] = desc if desc
      default = static_default(klass, option)
      unless default.equal?(NO_DEFAULT)
        schema["default"] = default
        schema["type"] ||= json_type(default) unless default.nil? || schema["enum"]
      end
      schema
    end

    def self.json_type(value)
      case value
      when true, false then "boolean"
      when Integer then "integer"
      when Numeric then "number"
      when String, Symbol then "string"
      when Array then "array"
      when Hash then "object"
      end
    end

    NO_DEFAULT = Object.new.freeze

    # A default that doesn't depend on the instance, other props or randomness; anything else
    # is left out (the component computes it)
    def self.static_default(klass, option)
      return NO_DEFAULT unless option.default

      first, second = 2.times.map { klass.allocate.instance_exec(&option.default) }
      return NO_DEFAULT unless first == second && json_value?(first)

      first.is_a?(Symbol) ? first.to_s : first
    rescue StandardError
      NO_DEFAULT
    end

    def self.json_value?(value)
      case value
      when String, Symbol, Numeric, true, false, nil then true
      when Array then value.all? { |item| json_value?(item) }
      when Hash then value.all? { |key, item| (key.is_a?(String) || key.is_a?(Symbol)) && json_value?(item) }
      else false
      end
    end
  end
end
