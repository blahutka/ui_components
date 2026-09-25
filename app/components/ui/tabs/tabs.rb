# Several panels sharing one region, one shown at a time.
#
#   Tabs(default_value: "overview") do
#     TabsList do
#       TabsTrigger(value: "overview") { "Overview" }
#       TabsTrigger(value: "activity") { "Activity" }
#     end
#     TabsContent(value: "overview") { "A snapshot of your workspace." }
#     TabsContent(value: "activity") { "Every change, newest first." }
#   end
#
# Each trigger is matched to the panel with the same `value:`. The root shares `variant:`
# (:pill, :line), `size:` and `orientation:`; the selected tab is rendered on the server, and the
# `ui--tabs` controller switches panels, slides the indicator and handles the arrow keys. Emits
# `ui--tabs:change` with { value }.
class UI::Tabs < UI::Base
  prop :value,         default: -> { nil }
  prop :default_value, default: -> { nil }
  prop :variant,       one_of(%i[ pill line ], :pill), default: -> { :pill }
  prop :size,          one_of(%i[ sm md lg ], :md), default: -> { :md }
  prop :orientation,   one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :id,            default: -> { "tabs-#{SecureRandom.hex(4)}" }

  attr_reader :variant, :size, :orientation

  def selected?(value) = !current.nil? && current.to_s == value.to_s
  def trigger_id(value) = "#{@id}-tab-#{key(value)}"
  def panel_id(value) = "#{@id}-panel-#{key(value)}"

  def view_template(&)
    provide(:ui_tabs, self) do
      div(**mix(defaults(id: @id, data: { slot: "tabs", orientation: @orientation, controller: "ui--tabs", action: "ui--tabs:select->ui--tabs#selectValue" }), @attributes.except(:class)),
        class: cn("flex gap-6 data-[orientation=horizontal]:flex-col", override: @attributes[:class]), &)
    end
  end

  private
    def current
      @value.nil? ? @default_value : @value
    end

    def key(value)
      value.to_s.parameterize.presence || value.to_s.unpack1("H*")
    end
end
