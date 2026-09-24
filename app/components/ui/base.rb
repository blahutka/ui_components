class UI::Base < Phlex::HTML
  MERGER = TailwindMerge::Merger.new

  private
    # Joins class lists; when the caller passes its own classes (`class:`),
    # tailwind_merge lets them override the component defaults (like cn() in Appica).
    def cn(*classes, override: nil)
      base = classes.flatten.compact.join(" ")

      if override.present?
        MERGER.merge("#{base} #{Array(override).join(" ")}")
      else
        base
      end
    end

    # Shares a parent component with its compound parts for the duration of
    # the block (the Phlex counterpart of a React context provider).
    def provide(key, value)
      previous = context[key]
      context[key] = value
      yield
    ensure
      context[key] = previous
    end

    # A component's default attributes minus the ones the caller sets itself, so a caller's
    # `aria_label:` or `role:` replaces the default instead of being appended by mix()
    # (data: still merges).
    def defaults(**attributes)
      attributes.except(*(@attributes.keys - [ :data ]))
    end

    def consume(key, component:)
      context[key] || raise(ArgumentError, "#{self.class.name} must be rendered inside #{component}")
    end
end
