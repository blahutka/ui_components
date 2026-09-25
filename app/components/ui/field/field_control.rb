# What a form control needs to sit in a Field: the field's id, name, description and state,
# with the caller's own attributes winning. Included by Input, Textarea, Checkbox, Switch…
module UI::FieldControl
  private
    # The enclosing Field, if any: it owns the control's id, label, description and state
    def field
      context[:ui_field]
    end

    def invalid?
      @invalid || [ true, "true" ].include?(@attributes[:aria_invalid]) || field&.invalid?
    end

    def disabled?
      @attributes[:disabled] || field&.disabled?
    end

    # The control's attributes: the component's (and the Field's) defaults, with the caller's
    # own keys replacing them rather than being appended (data: still merges). aria-invalid always
    # comes from invalid? so it's "true" (what CSS matches), whatever the caller passed.
    def control_attributes(defaults, attributes)
      attributes = attributes.except(:aria_invalid)
      mix(defaults.compact.except(*(attributes.keys - [ :data ])), attributes)
    end

    def flag(value)
      "" if value
    end
end
