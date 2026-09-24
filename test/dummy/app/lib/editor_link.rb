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
