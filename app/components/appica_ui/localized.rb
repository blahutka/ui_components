# Translations and locale-aware formatting for components (included in AppicaUI::Base).
#
#   t(".markets")                        # relative: under the component's scope
#   t("ui_components.countries.us")      # absolute
#
# The scope comes from the component's folder, so every part of a compound component shares
# it: appica_ui/blocks/revenue_summary/revenue_market.rb → ui_components.appica_ui.blocks.revenue_summary.
# The strings live next to the component in a `*.locales.yml` file (all languages in one file).
#
# Declare translated defaults right on the props (dry-initializer evaluates them per instance):
#
#   prop :title, default: -> { t(".title.#{@period}") }
#   prop :label, translated(".stats")     # a Symbol is a key (:orders), a String is shown as-is
module AppicaUI::Localized
  CURRENCY_UNITS = { "USD" => "$", "EUR" => "€", "GBP" => "£", "JPY" => "¥", "CZK" => "Kč" }.freeze

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Override the folder-derived scope: translation_scope "ui_components.shared.money"
    def translation_scope(scope = nil)
      if scope
        @translation_scope = scope
      else
        @translation_scope ||= derived_translation_scope
      end
    end

    # A prop coercer: Symbols are looked up under `scope` (".stats" → .stats.orders), anything
    # else is kept. dry-initializer passes the component as the second argument.
    def translated(scope)
      ->(value, component) { value.is_a?(Symbol) ? component.t("#{scope}.#{value}") : value }
    end

    private

    # ui_components.<kit path>.<component folder>, from where the class is defined
    def derived_translation_scope
      file = name && Module.const_source_location(name)&.first
      root = UiComponents::Engine::COMPONENTS_PATH.to_s + "/"

      if file&.start_with?(root)
        relative_directory = Pathname.new(file).dirname.relative_path_from(UiComponents::Engine::COMPONENTS_PATH)
        [ "ui_components", *relative_directory.each_filename ].join(".")
      else
        "ui_components.#{name.to_s.underscore.tr("/", ".")}"
      end
    end
  end

  # Rails-style lazy lookup: ".key" is relative to the component's scope
  def t(key, **options)
    key = key.to_s
    I18n.t(key.start_with?(".") ? "#{self.class.translation_scope}#{key}" : key, **options)
  end

  private

  # $48,210 / 48 210 $ / 48.210 $ - no decimals for whole amounts unless `precision:` says so
  def format_money(amount, currency:, precision: nil)
    ActiveSupport::NumberHelper.number_to_currency(amount, unit: CURRENCY_UNITS.fetch(currency.to_s.upcase, currency.to_s),
                                                   precision: precision || ((amount % 1).zero? ? 0 : 2), locale: I18n.locale)
  end

  # 1,208 / 1.208
  def format_count(value)
    ActiveSupport::NumberHelper.number_to_delimited(value, locale: I18n.locale)
  end

  # 45% / 12,4 % - with `sign: true` a leading + or − (for changes)
  def format_percent(value, precision: 0, sign: false)
    formatted = ActiveSupport::NumberHelper.number_to_percentage(value.abs, precision:, locale: I18n.locale)
    sign ? "#{value.negative? ? "−" : "+"}#{formatted}" : formatted
  end
end
