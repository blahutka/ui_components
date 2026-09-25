# The UI components bound to a Rails form's object - reached through `form.ui` on any form
# builder (form_with, form_for, fields_for):
#
#   <%= form_with model: @user do |form| %>
#     <%= form.ui.text_field :name, description: "As it appears on your profile" %>
#     <%= form.ui.number_field :age %>
#     <%= form.ui.select :locations, [ [ "Prague", "prg" ], [ "Berlin", "ber" ] ], { prompt: "Pick cities" }, { multiple: true } %>
#     <%= form.fields_for :address do |address| %>
#       <%= address.ui.text_field :city %>
#     <% end %>
#   <% end %>
#
# Each helper renders a Field (label, the control, description, error) with Rails' own name, id
# and value for the attribute - so the controller gets the params the plain helpers would send -
# the object's errors, and `required` / `maxlength` / `min` / `max` from its validators.
# `label:` overrides the label (`human_attribute_name`), `label: false` renders the control alone;
# other options go to the control.
class UI::FormBuilder
  TEXT_TYPES = { text_field: "text", email_field: "email", password_field: "password", telephone_field: "tel", url_field: "url", search_field: "search" }.freeze

  def initialize(form)
    @form = form
    @template = form.instance_variable_get(:@template)
  end

  TEXT_TYPES.each do |helper, type|
    define_method(helper) do |method, label: nil, description: nil, **options|
      value = type == "password" ? nil : value_for(method)
      field(method, label:, description:, id: options[:id], name: options[:name]) do |control|
        UI::Input.new(type:, value:, **constraints(method, type:), **control, **options)
      end
    end
  end
  alias_method :phone_field, :telephone_field

  def number_field(method, label: nil, description: nil, **options)
    field(method, label:, description:, id: options[:id], name: options[:name]) do |control|
      UI::NumberField.new(default_value: (value_for(method) unless options.key?(:value)), **constraints(method, type: "number"), **control, **options)
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
    value = options.key?(:selected) ? options[:selected] : value_for(method)
    value = nil if !multiple && value.to_s.empty?
    required = html_options.key?(:required) ? html_options.delete(:required) : constraints(method)[:required]

    field(method, label: options[:label], description: options[:description], multiple: !!multiple,
      id: html_options[:id], name: html_options.delete(:name)) do |control|
      UI::FormBuilderSelect.new(
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
  def field(method, label:, description:, multiple: false, id: nil, name: nil)
    name ||= @form.field_name(method, multiple:)
    id ||= @form.field_id(method)

    if label == false
      @template.render(yield(name:, id:))
    else
      @template.render(UI::FormBuilderField.new(
        field: { name:, id: "#{id}-field", control_id: id, error: errors_for(method) },
        label: label || human_name(method), description:, control: yield(name:, id:)
      ))
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
      when :presence then attributes[:required] = true
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

  # options_for_select's shapes: "a", [ "Label", "value" ], { "Label" => "value" }
  def normalize_choices(choices)
    Array(choices).to_h do |choice|
      label, value = !choice.is_a?(String) && choice.respond_to?(:first) && choice.respond_to?(:last) ? [ choice.first, choice.last ] : [ choice, choice ]
      [ value.to_s, label.to_s ]
    end
  end
end
