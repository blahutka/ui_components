require "test_helper"

class AppicaUI::LocalizedTest < ComponentTestCase
  class Labelled < AppicaUI::Base
    translation_scope "ui_components.appica_ui.blocks.revenue_summary"

    prop :label, translated(".stats")
    prop :title, default: -> { t(".markets") }

    def view_template
      span { @label }
    end
  end

  test "the scope comes from the component folder, shared by all parts" do
    assert_equal "ui_components.appica_ui.blocks.revenue_summary", AppicaUI::Blocks::RevenueSummary.translation_scope
    assert_equal "ui_components.appica_ui.blocks.revenue_summary", AppicaUI::Blocks::RevenueStat.translation_scope
    assert_equal "ui_components.appica_ui.toast", AppicaUI::ToastIcon.translation_scope
    assert_equal "ui_components.appica_ui.blocks", AppicaUI::Blocks::Base.translation_scope
  end

  test "translation_scope overrides it" do
    assert_equal "ui_components.appica_ui.blocks.revenue_summary", Labelled.translation_scope
  end

  test "t resolves .keys relative to the scope and other keys absolutely" do
    component = Labelled.new(label: "x")

    assert_equal "Top markets", component.t(".markets")
    assert_equal "Germany", component.t("ui_components.countries.de")
    assert_equal "Deutschland", I18n.with_locale(:de) { component.t("ui_components.countries.de") }
  end

  test "translated props look Symbols up and keep Strings; defaults translate per locale" do
    assert_equal "Orders", Labelled.new(label: :orders).instance_variable_get(:@label)
    assert_equal "New customers", Labelled.new(label: "New customers").instance_variable_get(:@label)
    assert_equal "Hlavní trhy", I18n.with_locale(:cs) { Labelled.new(label: :orders).instance_variable_get(:@title) }
  end

  test "formatting helpers follow the locale" do
    component = Labelled.new(label: "x")
    format = ->(locale) do
      I18n.with_locale(locale) do
        [ component.send(:format_money, 48_210, currency: "USD"), component.send(:format_money, 39.9, currency: "czk"),
          component.send(:format_count, 1_208), component.send(:format_percent, 12.38, precision: 1, sign: true),
          component.send(:format_percent, -3, sign: true) ]
      end
    end

    assert_equal [ "$48,210", "Kč39.90", "1,208", "+12.4%", "−3%" ], format.(:en)
    assert_equal [ "48.210 $", "39,90 Kč", "1.208", "+12,4 %", "−3 %" ], format.(:de)
  end
end
