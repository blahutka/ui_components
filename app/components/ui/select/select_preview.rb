# A button that opens a list to pick one option - or several with `multiple:`.
#
# @label Select
# @logical_path Actions & Inputs
# @component UI::Select
# @display width wide
# @display min_height 360px
class UI::SelectPreview < UI::BasePreview
  FRUITS = %w[ Apple Banana Blueberry Grapes Orange Strawberry ].freeze
  FRUIT_ITEMS = proc { FRUITS.each { |fruit| SelectItem(value: fruit) { fruit } } }

  # @label Usage
  # @param variant [Symbol] select { choices: [outline, soft] }
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param align_item_with_trigger [Boolean] toggle
  def default(variant: :outline, size: :md, align_item_with_trigger: true)
    phlex do
      Select(variant:, size:, align_item_with_trigger:, name: "fruit", class: "w-full max-w-70") do
        SelectTrigger(aria_label: "Pick a fruit") { SelectValue(placeholder: "Pick a fruit") }
        SelectContent { instance_exec(&FRUIT_ITEMS) }
      end
    end
  end

  def variants
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        %i[ outline soft ].each do |variant|
          Select(variant:) do
            SelectTrigger(aria_label: "Pick a fruit (#{variant})") { SelectValue(placeholder: "Pick a fruit") }
            SelectContent { instance_exec(&FRUIT_ITEMS) }
          end
        end
      end
    end
  end

  # `size:` scales the trigger, popup radius and items together.
  def sizes
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        %i[ sm md lg ].each do |size|
          Select(size:) do
            SelectTrigger(aria_label: "Pick a fruit (#{size})") { SelectValue(placeholder: "Pick a fruit") }
            SelectContent { instance_exec(&FRUIT_ITEMS) }
          end
        end
      end
    end
  end

  # @label Grouped options
  def grouped
    phlex do
      Select(class: "w-full max-w-70") do
        SelectTrigger(aria_label: "Pick a food") { SelectValue(placeholder: "Pick a food") }
        SelectContent do
          SelectGroup do
            SelectGroupLabel { "Fruits" }
            %w[ Apple Banana Orange Strawberry ].each { |food| SelectItem(value: food) { food } }
          end
          SelectSeparator()
          SelectGroup do
            SelectGroupLabel { "Vegetables" }
            %w[ Carrot Potato Tomato ].each { |food| SelectItem(value: food) { food } }
            SelectItem(value: "Broccoli", disabled: true) { "Broccoli" }
          end
        end
      end
    end
  end

  # `clearable: true` on the trigger adds a ✕ once there's a value (Delete / Backspace clear too).
  def clearable
    phlex do
      Select(default_value: "Orange", class: "w-full max-w-70") do
        SelectTrigger(clearable: true, aria_label: "Pick a fruit") { SelectValue(placeholder: "Pick a fruit") }
        SelectContent { instance_exec(&FRUIT_ITEMS) }
      end
    end
  end

  # @label Disabled & error states
  def states
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        Select(disabled: true) do
          SelectTrigger(aria_label: "Disabled") { SelectValue(placeholder: "Disabled") }
          SelectContent { instance_exec(&FRUIT_ITEMS) }
        end
        Select(default_value: "Orange") do
          SelectTrigger(aria_invalid: true, aria_label: "With error") { SelectValue(placeholder: "Pick a fruit") }
          SelectContent { instance_exec(&FRUIT_ITEMS) }
        end
      end
    end
  end

  # @label Start & end slots
  # With a start slot, open below the trigger (`align_item_with_trigger: false`).
  def slots
    phlex do
      Select(default_value: "Credit card", align_item_with_trigger: false, class: "w-full max-w-70") do
        SelectTrigger(aria_label: "Payment method", start_slot: :credit_card, end_slot: -> { span(class: "text-foreground-subtle text-xs") { "Default" } }) do
          SelectValue(placeholder: "Payment method")
        end
        SelectContent { [ "Credit card", "PayPal", "Bank transfer", "Apple Pay", "Google Pay" ].each { |method| SelectItem(value: method) { method } } }
      end
    end
  end

  # @label Country select
  # `start_slot: :selected` mirrors the selected item's flag into the trigger.
  def countries
    phlex do
      Select(default_value: "us", align_item_with_trigger: false, name: "country", class: "w-full max-w-70") do
        SelectTrigger(aria_label: "Select a country", start_slot: :selected) { SelectValue(placeholder: "Select a country") }
        SelectContent do
          %w[ au br ca fr de jp gb us ].each do |code|
            SelectItem(value: code) do
              CountryFlag(code, class: "size-4.5 text-base", data: { icon: "start" })
              plain I18n.t("ui_components.countries.#{code}", default: code.upcase)
            end
          end
        end
      end
    end
  end

  # @label Showing a label for the value
  # When values differ from labels, `items:` lets the closed trigger show "Pro" instead of "pro".
  def labels
    plans = { free: "Free", pro: "Pro", enterprise: "Enterprise" }
    phlex do
      Select(default_value: "pro", items: plans, name: "plan", class: "w-full max-w-70") do
        SelectTrigger(aria_label: "Plan") { SelectValue() }
        SelectContent { plans.each { |value, label| SelectItem(value:) { label } } }
      end
    end
  end

  # @label Multiple selection
  # Selected items keep a check; `SelectValue(summary:)` words the count.
  def multiple
    phlex do
      Select(multiple: true, default_value: %w[ Pepperoni Mushrooms ], name: "toppings", class: "w-full max-w-70") do
        SelectTrigger(clearable: true, aria_label: "Choose toppings") { SelectValue(placeholder: "Choose toppings", summary: "%{count} toppings") }
        SelectContent { %w[ Pepperoni Mushrooms Onions Olives Peppers Bacon Pineapple ].each { |topping| SelectItem(value: topping) { topping } } }
      end
    end
  end

  # @label In a form
  # Inside a Field it's labelled and validated like any control: submit without a choice.
  def form
    phlex do
      form(class: "flex w-full max-w-70 flex-col items-start gap-4", data: { demo: "form" }) do
        Field(name: "fruit", messages: { value_missing: "Pick a fruit to continue." }, class: "w-full") do
          FieldLabel { "Favorite fruit" }
          Select(required: true) do
            SelectTrigger { SelectValue(placeholder: "Pick a fruit") }
            SelectContent { instance_exec(&FRUIT_ITEMS) }
          end
          FieldError()
        end
        Button(type: "submit", size: :sm) { "Continue" }
      end
      script(type: "module") do
        raw safe(%(document.querySelector("[data-demo=form]").addEventListener("submit", event => event.preventDefault())))
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl", class: "w-full max-w-70") do
        Select(default_value: "تفاح") do
          SelectTrigger(aria_label: "اختر فاكهة") { SelectValue(placeholder: "اختر فاكهة") }
          SelectContent { %w[ تفاح موز برتقال فراولة ].each { |fruit| SelectItem(value: fruit) { fruit } } }
        end
      end
    end
  end
end
