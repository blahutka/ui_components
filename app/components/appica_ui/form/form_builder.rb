# The UI components bound to a Rails form's object - reached through `form.ux` on any form
# builder (form_with, form_for, fields_for):
#
#   <%= form_with model: @user do |form| %>
#     <%= form.ux.text_field :name, description: "As it appears on your profile" %>
#     <%= form.ux.number_field :age %>
#     <%= form.ux.select :locations, [ [ "Prague", "prg" ], [ "Berlin", "ber" ] ], { prompt: "Pick cities" }, { multiple: true } %>
#     <%= form.ux.text_area :bio %>
#     <%= form.ux.radio_group :plan, [ [ "Free", "free" ], [ "Pro", "pro" ] ] %>
#     <%= form.ux.checkbox_group :interests, [ [ "Design", "design" ], [ "Sales", "sales" ] ] %>
#     <%= form.ux.combobox :language, [ [ "Czech", "cs" ], [ "English", "en" ] ] %>
#     <%= form.ux.range_field :experience, max: 30 %>
#     <%= form.ux.otp_field :pin, length: 4 %>
#     <%= form.ux.switch :newsletter %>
#     <%= form.ux.check_box :terms_of_service %>
#     <%= form.ux.chip_group :tags, %w[ ruby rails ] %>
#     <%= form.ux.autocomplete :city, %w[ Prague Berlin ] %>
#     <%= form.ux.rating :score %>
#     <%= form.ux.toggle :featured %>
#     <%= form.ux.toggle_group :alignment, %w[ left center right ] %>
#     <%= form.fields_for :address do |address| %>
#       <%= address.ux.text_field :city %>
#     <% end %>
#   <% end %>
#
# Each helper renders a Field (label, the control, description, error) with Rails' own name, id
# and value for the attribute - so the controller gets the params the plain helpers would send -
# the object's errors, and `required` / `maxlength` / `min` / `max` from its validators.
# `label:` overrides the label (`human_attribute_name`), `label: false` renders the control alone;
# other options go to the control.
class AppicaUI::FormBuilder
  TEXT_TYPES = { text_field: "text", email_field: "email", password_field: "password", telephone_field: "tel", url_field: "url", search_field: "search", date_field: "date" }.freeze

  def initialize(form)
    @form = form
    @template = form.instance_variable_get(:@template)
  end

  TEXT_TYPES.each do |helper, type|
    define_method(helper) do |method, label: nil, description: nil, **options|
      value = options.delete(:value) { type == "password" ? nil : value_for(method) }
      field(method, label:, description:, id: options[:id], name: options[:name]) do |control|
        AppicaUI::Input.new(type:, value:, **constraints(method, type:), **control, **options)
      end
    end
  end
  alias_method :phone_field, :telephone_field

  def number_field(method, label: nil, description: nil, **options)
    field(method, label:, description:, id: options[:id], name: options[:name]) do |control|
      AppicaUI::NumberField.new(default_value: (value_for(method) unless options.key?(:value)), **constraints(method, type: "number"), **control, **options)
    end
  end

  def text_area(method, label: nil, description: nil, **options)
    field(method, label:, description:, id: options[:id], name: options[:name]) do |control|
      AppicaUI::Textarea.new(value: (value_for(method) unless options.key?(:value)), **constraints(method, type: "textarea"), **control, **options)
    end
  end
  alias_method :textarea, :text_area

  # Rails' signature: check_box(method, options = {}, checked_value = "1", unchecked_value = "0").
  # The unchecked value goes in a hidden input first, so an unticked box still submits
  # (`include_hidden: false` leaves it out).
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    boolean_control(AppicaUI::Checkbox, method, options, checked_value, unchecked_value)
  end
  alias_method :checkbox, :check_box

  # A check box drawn as a switch - same signature and params as check_box
  def switch(method, options = {}, checked_value = "1", unchecked_value = "0")
    boolean_control(AppicaUI::Switch, method, options, checked_value, unchecked_value)
  end

  # One RadioGroup for the attribute, a Radio per choice (the choices select accepts)
  def radio_group(method, choices, label: nil, description: nil, include_hidden: true, **options)
    value = options.key?(:value) ? options.delete(:value) : attribute_value(method)
    required = options.key?(:required) ? options.delete(:required) : constraints(method)[:required]

    field(method, label:, description:, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderChoices.new(type: :radio, id: control[:id], items: normalize_choices(choices), hidden_name: (control[:name] if include_hidden),
        group: { id: control[:id], name: control[:name], value: value&.to_s, required: !!required, **options })
    end
  end

  # One CheckboxGroup for an array attribute, a Checkbox per choice; submits `name[]`
  def checkbox_group(method, choices, label: nil, description: nil, include_hidden: true, **options)
    value = options.key?(:value) ? options.delete(:value) : attribute_value(method)

    field(method, label:, description:, multiple: true, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderChoices.new(type: :checkbox, id: control[:id], items: normalize_choices(choices), hidden_name: (control[:name] if include_hidden),
        group: { id: control[:id], name: control[:name], value: Array(value).map(&:to_s), **options })
    end
  end

  # Selectable Chips for an array attribute (like checkbox_group); submits `name[]`
  def chip_group(method, choices, label: nil, description: nil, include_hidden: true, **options)
    value = options.key?(:value) ? options.delete(:value) : attribute_value(method)

    field(method, label:, description:, multiple: true, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderChoices.new(type: :chip, id: control[:id], items: normalize_choices(choices), hidden_name: (control[:name] if include_hidden),
        group: { name: control[:name], value: Array(value).map(&:to_s), **options })
    end
  end

  # Rails' signature: collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {})
  def collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {})
    radio_group(method, collection_choices(collection, value_method, text_method), **collection_options(options, html_options))
  end

  # Rails' signature: collection_check_boxes(method, collection, value_method, text_method, options = {}, html_options = {})
  def collection_check_boxes(method, collection, value_method, text_method, options = {}, html_options = {})
    checkbox_group(method, collection_choices(collection, value_method, text_method), **collection_options(options, html_options))
  end

  # Rails' signature: collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    select(method, collection_choices(collection, value_method, text_method), options, html_options)
  end

  # A searchable Select: a Combobox with an input, or chips for `multiple: true` (`name[]`, with
  # an empty hidden entry first like a multiple select). Other options go to the Combobox
  # (`clearable:`, `variant:`, `size:`…).
  def combobox(method, choices, label: nil, description: nil, multiple: false, placeholder: nil, include_hidden: true, **options)
    value = options.key?(:value) ? options.delete(:value) : attribute_value(method)
    value = multiple ? Array(value).map(&:to_s).compact_blank : value.to_s.presence
    required = options.key?(:required) ? options.delete(:required) : constraints(method)[:required]

    field(method, label:, description:, multiple:, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderCombobox.new(items: normalize_choices(choices), placeholder:, input: {},
        combobox: { id: "#{control[:id]}-combobox", name: control[:name], value:, multiple:, include_hidden:, required: !!required, **options })
    end
  end

  # Free text with suggestions: an Autocomplete submitting what's typed (or picked)
  def autocomplete(method, suggestions, label: nil, description: nil, placeholder: nil, **options)
    value = options.key?(:value) ? options.delete(:value) : value_for(method)
    input = constraints(method, type: "text").merge(options.extract!(:required, :maxlength, :autofocus))

    field(method, label:, description:, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderAutocomplete.new(placeholder:, input:,
        autocomplete: { id: "#{control[:id]}-autocomplete", items: Array(suggestions), name: control[:name], value: value&.to_s, **options })
    end
  end

  # A Rating; its hidden input submits the score ("0" once cleared)
  def rating(method, label: nil, description: nil, **options)
    field(method, label:, description:, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::Rating.new(value: (value_for(method) unless options.key?(:value)), name: control[:name], **options)
    end
  end

  # A Toggle button with check_box's signature and params: checked_value while pressed, the
  # unchecked value (in the same hidden input) while released. The button shows the label.
  def toggle(method, options = {}, checked_value = "1", unchecked_value = "0")
    options = options.dup
    text = options.delete(:label) || human_name(method)
    description = options.delete(:description)
    include_hidden = options.delete(:include_hidden) { true }
    pressed = options.key?(:checked) ? options.delete(:checked) : checked?(attribute_value(method), checked_value)

    field(method, label: text, description:, layout: :control, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderToggle.new(text:, button: options,
        toggle: { id: control[:id], name: control[:name], value: checked_value, unchecked_value: (unchecked_value if include_hidden), pressed: })
    end
  end

  # A ToggleGroup, a Toggle button per choice: one value, or `multiple: true` for `name[]`.
  # An empty hidden entry goes first, like a radio group or multiple select.
  def toggle_group(method, choices, label: nil, description: nil, multiple: false, include_hidden: true, **options)
    value = options.key?(:value) ? options.delete(:value) : attribute_value(method)

    field(method, label:, description:, multiple:, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderToggleGroup.new(id: control[:id], items: normalize_choices(choices),
        group: { id: control[:id], name: control[:name], value: Array(value).map(&:to_s).compact_blank, multiple:, include_hidden:, **options })
    end
  end

  # A Slider; `min` / `max` / `step` come from numericality validators like number_field's.
  # Its thumb tooltip gets room below the label.
  def range_field(method, label: nil, description: nil, **options)
    options[:class] = [ ("pt-6" unless options[:tooltip] == :never), options[:class] ].compact.join(" ")

    field(method, label:, description:, id: options.delete(:id), name: options[:name]) do |control|
      AppicaUI::Slider.new(default_value: (value_for(method) unless options.key?(:value)), **constraints(method, type: "number").slice(:min, :max, :step), name: control[:name], **options)
    end
  end
  alias_method :slider, :range_field

  # An OTPField of `length` characters, submitted as one value
  def otp_field(method, length: 6, label: nil, description: nil, **options)
    required = options.key?(:required) ? options.delete(:required) : constraints(method)[:required]

    field(method, label:, description:, id: options.delete(:id), name: options.delete(:name)) do |control|
      AppicaUI::FormBuilderOTP.new(id: control[:id], otp: { length:, value: (value_for(method) unless options.key?(:value)), name: control[:name], required: !!required, **options })
    end
  end

  # Rails' signature: select(method, choices, options = {}, html_options = {})
  def select(method, choices = nil, options = {}, html_options = {})
    options = options.dup
    html_options = html_options.dup
    items = normalize_choices(choices)
    multiple = html_options.delete(:multiple)
    placeholder = if options[:prompt]
      options[:prompt].is_a?(String) ? options[:prompt] : @template.t("helpers.select.prompt", default: "Please select")
    elsif options[:include_blank]
      options[:include_blank].is_a?(String) ? options[:include_blank] : ""
    end
    value = options.key?(:selected) ? options[:selected] : attribute_value(method)
    value = nil if !multiple && value.to_s.empty?
    required = html_options.key?(:required) ? html_options.delete(:required) : constraints(method)[:required]

    field(method, label: options[:label], description: options[:description], multiple: !!multiple,
      id: html_options[:id], name: html_options.delete(:name)) do |control|
      AppicaUI::FormBuilderSelect.new(
        select: {
          default_value: multiple ? Array(value).compact.map(&:to_s).reject(&:empty?) : value&.to_s, items:, multiple: multiple.present?,
          include_hidden: options.fetch(:include_hidden, true), required:,
          disabled: html_options.delete(:disabled), name: control[:name]
        }.compact,
        trigger: { id: control[:id], **html_options },
        placeholder:, items:
      )
    end
  end

  private

  # A Field around the control, or the bare control (with its name and id) for `label: false`
  def field(method, label:, description:, multiple: false, layout: :stacked, id: nil, name: nil)
    name ||= @form.field_name(method, multiple:)
    id ||= @form.field_id(method)

    if label == false
      @template.render(yield(name:, id:))
    else
      @template.render(AppicaUI::FormBuilderField.new(
        field: { name:, id: "#{id}-field", control_id: id, error: errors_for(method) },
        label: label || human_name(method), description:, layout:, control: yield(name:, id:)
      ))
    end
  end

  def boolean_control(component, method, options, checked_value, unchecked_value)
    options = options.dup
    label = options.delete(:label)
    description = options.delete(:description)
    include_hidden = options.delete(:include_hidden) { true }
    checked = options.key?(:checked) ? options.delete(:checked) : checked?(attribute_value(method), checked_value)

    field(method, label:, description:, layout: :inline, id: options[:id], name: options[:name]) do |control|
      component.new(value: checked_value, unchecked_value: (unchecked_value if include_hidden), checked:,
        **constraints(method).slice(:required), **control, **options)
    end
  end

  # Rails' CheckBox#checked?: booleans, "1", 1 and collections containing the checked value
  def checked?(value, checked_value)
    case value
    when TrueClass, FalseClass then value == !!checked_value
    when NilClass then false
    when String then value == checked_value.to_s
    else value.respond_to?(:include?) ? value.include?(checked_value) : value.to_i == checked_value.to_i
    end
  end

  # The value as it was set (so an invalid "abc" re-renders as typed), like Rails' helpers
  def value_for(method)
    object = @form.object
    return unless object

    if object.respond_to?("#{method}_before_type_cast")
      object.public_send("#{method}_before_type_cast")
    elsif (set = object.instance_variable_get(:@attributes)).is_a?(ActiveModel::AttributeSet) && set.key?(method.to_s)
      set[method.to_s].value_before_type_cast
    elsif object.respond_to?(method)
      object.public_send(method)
    end
  end

  # The cast value, which check boxes, radios and comboboxes compare against (like Rails)
  def attribute_value(method)
    object = @form.object
    object.public_send(method) if object.respond_to?(method)
  end

  def errors_for(method)
    object = @form.object
    object.errors[method].to_sentence.presence if object.respond_to?(:errors)
  end

  def human_name(method)
    object = @form.object
    object.class.respond_to?(:human_attribute_name) ? object.class.human_attribute_name(method) : method.to_s.humanize
  end

  # required / maxlength / min / max / step from unconditional validators
  def constraints(method, type: nil)
    object = @form.object
    return {} unless object.class.respond_to?(:validators_on)

    object.class.validators_on(method).reject { |validator| (validator.options.keys & %i[ if unless on ]).any? }.each_with_object({}) do |validator, attributes|
      options = validator.options
      case validator.kind
      when :presence, :acceptance then attributes[:required] = true
      when :length
        maximum = options[:maximum]
        attributes[:maxlength] = maximum if type && type != "number" && maximum.is_a?(Numeric)
      when :numericality
        range = options[:in]
        minimum = options[:greater_than_or_equal_to] || range&.begin
        maximum = options[:less_than_or_equal_to] || (range.end if range && !range.exclude_end?)
        attributes[:min] = minimum if minimum.is_a?(Numeric)
        attributes[:max] = maximum if maximum.is_a?(Numeric)
        attributes[:step] = 1 if options[:only_integer] == true && type == "number"
      end
    end.compact.then { |attributes| type == "number" ? attributes.slice(:required, :min, :max, :step) : attributes.except(:min, :max, :step) }
  end

  # [ text, value ] pairs, from methods or procs like options_from_collection_for_select
  def collection_choices(collection, value_method, text_method)
    collection.map { |item| [ read(item, text_method), read(item, value_method) ] }
  end

  def read(item, method)
    method.respond_to?(:call) ? method.call(item) : item.public_send(method)
  end

  # Rails' collection helpers split their options: `checked:` becomes the value
  def collection_options(options, html_options)
    options = options.symbolize_keys
    options[:value] = options.delete(:checked) if options.key?(:checked)
    { **html_options.symbolize_keys, **options.slice(:label, :description, :include_hidden, :value, :required, :disabled) }
  end

  # options_for_select's shapes: "a", [ "Label", "value" ], { "Label" => "value" }
  def normalize_choices(choices)
    Array(choices).to_h do |choice|
      label, value = !choice.is_a?(String) && choice.respond_to?(:first) && choice.respond_to?(:last) ? [ choice.first, choice.last ] : [ choice, choice ]
      [ value.to_s, label.to_s ]
    end
  end
end
