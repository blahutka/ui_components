# Declarative component props on top of dry-initializer. Declared props become ivars (@name) -
# without public readers, so a prop called `title` or `label` doesn't shadow Phlex's element
# methods - and every other keyword (class:, id:, data:, aria_*) is kept in @attributes for the
# root element, like the hand-written `**attributes` catch-all.
#
#   include UI::Props
#
#   prop :value
#   prop :title, default: -> { "Revenue" }
#   prop :variant, one_of(VARIANTS, :primary), default: -> { :primary }
#   param :code, ->(value) { value.to_s.downcase.to_sym }   # positional
#
# Classes that still define their own `initialize` are left untouched.
module UI::Props
  def self.included(base)
    base.extend Dry::Initializer
    base.extend ClassMethods
  end

  module ClassMethods
    def prop(name, type = nil, **options)
      option(name, *type, reader: false, **options)
    end

    def param(name, type = nil, **options)
      super(name, *type, reader: false, **options)
    end

    # A coercer for enum-like props: the value as a symbol when it's one of `choices` (an
    # Array, or a Hash's keys), otherwise `fallback`
    def one_of(choices, fallback)
      ->(value) { choices.include?(value.to_sym) ? value.to_sym : fallback }
    end

    # Phlex::SGML.new keeps the content block; only the keywords are split first
    def new(*params, **options, &)
      return super unless instance_method(:initialize).owner == Dry::Initializer::Mixin::Root

      known = dry_initializer.options.map(&:source)
      super(*params, **options.slice(*known), &).tap do |component|
        component.instance_variable_set(:@attributes, options.except(*known))
      end
    end
  end
end
