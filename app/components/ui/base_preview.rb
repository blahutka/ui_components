# Base class for the co-located Lookbook previews (app/components/ui/**/*_preview.rb).
# `phlex { ... }` renders the block as a Phlex view with the UI kit included, so a
# scenario reads exactly like application code: Autocomplete(items: ...) { ... }
#
# @hidden
class UI::BasePreview < Lookbook::Preview
  class Example < UI::Base
    # Phlex::SGML.new keeps a passed block as the content block, so the template is a keyword
    def initialize(template:)
      @template = template
    end

    def view_template
      instance_exec(&@template)
    end
  end

  private
    def phlex(&template)
      render Example.new(template:)
    end
end
