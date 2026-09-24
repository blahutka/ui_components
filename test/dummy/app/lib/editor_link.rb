# Links that open a file (at a line) in your editor, for the Lookbook "Editor" panel.
#
# The panel links to the dev server (EditorOpeningsController), which hands the editor URL to
# the OS - so they work in any browser, including embedded ones that don't open x-mine://.
#
# RubyMine by default (x-mine://). Pick another editor with
# LOOKBOOK_EDITOR=vscode|cursor|idea|zed, or give a full template with %{file} and %{line}:
#   LOOKBOOK_EDITOR="myeditor://open?path=%{file}&l=%{line}"
module EditorLink
  TEMPLATES = {
    "rubymine" => "x-mine://open?file=%{file}&line=%{line}",
    "idea" => "idea://open?file=%{file}&line=%{line}",
    "vscode" => "vscode://file/%{file}:%{line}",
    "cursor" => "cursor://file/%{file}:%{line}",
    "zed" => "zed://file/%{file}:%{line}"
  }.freeze

  extend self

  # The editor's own URL, e.g. x-mine://open?file=…&line=12
  def url(file, line = 1)
    format(template, file: ERB::Util.url_encode(file.to_s).gsub("%2F", "/"), line: line || 1)
  end

  # The dev-server route that opens it (see config/routes.rb)
  def open_path(file, line = 1)
    "/editor/open?#{{ file: file.to_s, line: line || 1 }.to_query}"
  end

  # Only files inside this project can be opened
  def openable?(file)
    path = Pathname(file.to_s).expand_path
    path.file? && path.realpath.to_s.start_with?("#{UiComponents::Engine.root.realpath}/")
  end

  NAMES = { "rubymine" => "RubyMine", "idea" => "IntelliJ IDEA", "vscode" => "VS Code", "cursor" => "Cursor", "zed" => "Zed" }.freeze

  def editor_name
    NAMES.fetch(ENV.fetch("LOOKBOOK_EDITOR", "rubymine"), "your editor")
  end

  # Where a preview scenario method is defined: [file, line]
  def scenario_location(preview, scenario)
    preview.preview_class.instance_method(scenario.name).source_location
  rescue NameError
    [ preview.file_path.to_s, 1 ]
  end

  # Every file in the preview's component folder: parts, Stimulus controller, CSS, preview
  def component_files(preview)
    Dir.glob(preview.file_path.dirname.join("*")).select { |path| File.file?(path) }.sort_by do |path|
      [ path.end_with?("_preview.rb") ? 1 : 0, File.extname(path) == ".rb" ? 0 : 1, path ]
    end
  end

  # The file's type, from its (compound) extension: card.md.erb → :markdown, show.html.erb → :html
  def file_type(path)
    name = File.basename(path.to_s)
    case name
    when /\.md(\.erb)?\z/, /\.markdown\z/ then :markdown
    when /\.html(\.\w+)?\z/, /\.erb\z/ then :html
    when /\.rb\z/, /\.rake\z/, "Gemfile" then :ruby
    when /\.(js|mjs)\z/ then :js
    when /\.scss\z/ then :scss
    when /\.css\z/ then :css
    else :file
    end
  end

  # A 16px badge for the file type (inline SVG)
  def icon(path)
    ICONS.fetch(file_type(path)).html_safe
  end

  TILE = ->(color, text, text_color: "#fff", size: 7) do
    %(<svg class="file-icon" viewBox="0 0 16 16" aria-hidden="true"><rect x="0.5" y="0.5" width="15" height="15" rx="3" fill="#{color}"/>) +
      %(<text x="8" y="11" text-anchor="middle" font-family="ui-sans-serif, system-ui, sans-serif" font-size="#{size}" font-weight="700" fill="#{text_color}">#{text}</text></svg>)
  end

  ICONS = {
    ruby: %(<svg class="file-icon" viewBox="0 0 16 16" aria-hidden="true"><path d="M4.5 2.5h7l3 4-6.5 7.5L1.5 6.5z" fill="#CC342D"/>) +
      %(<path d="M1.5 6.5h13M4.5 2.5 6 6.5l2 7.5 2-7.5 1.5-4M6 6.5h4" fill="none" stroke="#fff" stroke-opacity=".55" stroke-width=".8" stroke-linejoin="round"/></svg>),
    js: TILE.call("#F7DF1E", "JS", text_color: "#1f1f1f"),
    html: TILE.call("#E34F26", "&lt;&gt;", size: 7.5),
    css: TILE.call("#1572B6", "{}", size: 8),
    scss: TILE.call("#CF649A", "S", size: 9),
    markdown: TILE.call("#6B7280", "M&#8595;", size: 6.5),
    file: %(<svg class="file-icon" viewBox="0 0 16 16" aria-hidden="true"><path d="M4 1.5h5.5L13 5v9.5H4z" fill="none" stroke="#9CA3AF" stroke-width="1.2" stroke-linejoin="round"/>) +
      %(<path d="M9.5 1.5V5H13" fill="none" stroke="#9CA3AF" stroke-width="1.2" stroke-linejoin="round"/></svg>)
  }.freeze

  # The docs page for the component, matched by name (card_preview.rb → docs/**/card.md.erb)
  def docs_file(preview)
    name = preview.file_path.basename.to_s.delete_suffix("_preview.rb")
    Dir.glob(UiComponents::Engine.root.join("docs/lookbook/**/#{name}.md.erb")).first
  end

  private
    def template
      editor = ENV.fetch("LOOKBOOK_EDITOR", "rubymine")
      TEMPLATES.fetch(editor, editor.include?("%{file}") ? editor : TEMPLATES["rubymine"])
    end
end
