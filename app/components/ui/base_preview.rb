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
    # Resolved from the top level on every call: Lookbook can hold on to a preview
    # instance from before a code reload, and a lexical `Example` would then point at
    # the unloaded UI kit, whose component methods (`Button(...)`) no longer exist.
    def phlex(&template)
      render ::UI::BasePreview::Example.new(template:)
    end
end
