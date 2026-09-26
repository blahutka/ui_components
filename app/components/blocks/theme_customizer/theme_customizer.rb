# A theme settings panel like Appica's: mode, base / primary / secondary colors (a Tailwind
# scale or any custom color), font and radius, "Get CSS Code", "Disable animations" and a reset -
# composed from ToggleGroup, Select, Input, Switch, Button, Dialog and CopyButton.
#
#   ThemeCustomizer()
#
# Every change repaints the page at once and is kept in localStorage; pages that import
# `blocks/theme_customizer/theme` and call watchStoredTheme() follow it (the dummy app does, so the
# whole Lookbook takes the theme). "Get CSS Code" shows only the variables that changed - put
# them in your stylesheet *after* `@import ".../ui/index.css"`, never in place of ui/theme.css.
# The generator (theme.js) is a port of appica.dev's, so its output matches theirs.
# Strings: theme_customizer.locales.yml.
class Blocks::ThemeCustomizer < Blocks::Base
  PALETTE_500 = {
    slate: "oklch(55.4% 0.046 257.417)", gray: "oklch(55.1% 0.027 264.364)", zinc: "oklch(55.2% 0.016 285.938)",
    neutral: "oklch(55.6% 0 0)", stone: "oklch(55.3% 0.013 58.071)", taupe: "oklch(54.7% 0.021 43.1)",
    mauve: "oklch(54.2% 0.034 322.5)", mist: "oklch(56% 0.021 213.5)", olive: "oklch(58% 0.031 107.3)",
    red: "oklch(63.7% 0.237 25.331)", orange: "oklch(70.5% 0.213 47.604)", amber: "oklch(76.9% 0.188 70.08)",
    yellow: "oklch(79.5% 0.184 86.047)", lime: "oklch(76.8% 0.233 130.85)", green: "oklch(72.3% 0.219 149.579)",
    emerald: "oklch(69.6% 0.17 162.48)", teal: "oklch(70.4% 0.14 182.503)", cyan: "oklch(71.5% 0.143 215.221)",
    sky: "oklch(68.5% 0.169 237.323)", blue: "oklch(62.3% 0.214 259.815)", indigo: "oklch(58.5% 0.233 277.117)",
    violet: "oklch(60.6% 0.25 292.717)", purple: "oklch(62.7% 0.265 303.9)", fuchsia: "oklch(66.7% 0.295 322.15)",
    pink: "oklch(65.6% 0.241 354.308)", rose: "oklch(64.5% 0.246 16.439)"
  }.freeze
  NEUTRALS = %i[ slate gray zinc neutral stone taupe mauve mist olive ].freeze
  ACCENTS = %i[ red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose ].freeze
  RAINBOW = "conic-gradient(from 0deg, oklch(63% 0.25 29), oklch(79% 0.17 70), oklch(87% 0.19 110), oklch(75% 0.16 160), " \
    "oklch(72% 0.14 200), oklch(62% 0.21 260), oklch(56% 0.29 302), oklch(65% 0.25 350), oklch(63% 0.25 29))"
  FONTS = {
    system: "System", geist: "Geist", "geist-mono": "Geist Mono", inter: "Inter", figtree: "Figtree", urbanist: "Urbanist",
    "dm-sans": "DM Sans", outfit: "Outfit", manrope: "Manrope", fraunces: "Fraunces", "public-sans": "Public Sans",
    "instrument-sans": "Instrument Sans", "host-grotesk": "Host Grotesk", "jetbrains-mono": "JetBrains Mono"
  }.freeze
  RADII = { none: :border_corner_square, xsmall: :border_corner_rounded, small: :border_corner_rounded,
            medium: :border_corner_ios, large: :border_corner_ios, xlarge: :border_corner_pill }.freeze
  MODES = { light: :sun, dark: :moon, system: :device_desktop }.freeze

  prop :title, default: -> { t(".title") }
  prop :id,    default: -> { "theme-customizer-#{SecureRandom.hex(4)}" }

  def view_template
    div(**mix(defaults(id: @id, data: {
      slot: "theme-customizer", controller: "blocks--theme-customizer",
      action: "ui--select:change->blocks--theme-customizer#selectChanged ui--toggle-group:change->blocks--theme-customizer#modeChanged"
    }), @attributes.except(:class)), class: cn(
      "bg-background border-border-muted flex flex-col gap-6 rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
      override: @attributes[:class]
    )) do
      h2(class: "text-foreground-intense text-xl font-semibold") { @title }
      mode_picker
      div(class: "bg-background-muted flex flex-col gap-5 rounded-lg p-4", data: { slot: "theme-customizer-settings" }) do
        setting(:base) { color_select(:base, NEUTRALS, default: "gray") }
        setting(:primary) do
          color_select(:primary, ACCENTS, default: "base", custom: true, base: true)
          custom_color(:primary, "#3b82f6")
        end
        setting(:secondary) do
          color_select(:secondary, ACCENTS, default: "blue", custom: true)
          custom_color(:secondary, "#00bc7d")
        end
        setting(:font) { font_select }
        setting(:radius) { radius_select }
        css_dialog
      end
      label(class: "flex items-center justify-between gap-4 text-sm font-medium text-foreground-intense") do
        plain t(".disable_animations")
        Switch(data: { "blocks--theme-customizer-target": "animations", action: "change->blocks--theme-customizer#animationsChanged" })
      end
      Button(variant: :outline, class: "w-full", data: { action: "blocks--theme-customizer#reset" }) do
        Icon(:restore, data: { icon: "start" })
        plain t(".reset")
      end
    end
  end

  private
    def mode_picker
      div(class: "flex flex-col gap-2") do
        span(class: "text-foreground-intense text-sm font-medium", id: "#{@id}-mode") { t(".mode") }
        ToggleGroup(default_value: [ "system" ], aria_labelledby: "#{@id}-mode", class: "grid w-full grid-cols-3",
          data: { "blocks--theme-customizer-target": "mode" }) do
          MODES.each do |mode, icon|
            Toggle(value: mode.to_s) do |toggle|
              Button(**toggle, variant: :ghost, class: "data-pressed:bg-background-muted w-full") do
                Icon(icon, data: { icon: "start" })
                plain t(".modes.#{mode}")
              end
            end
          end
        end
      end
    end

    def setting(name, &)
      div(class: "flex flex-col gap-2", data: { slot: "theme-customizer-setting", setting: name }) do
        span(class: "text-foreground-intense text-sm font-medium", id: "#{@id}-#{name}") { t(".#{name}") }
        yield
      end
    end

    # A Select of colors, each with its swatch (mirrored into the trigger)
    def color_select(name, colors, default:, custom: false, base: false)
      Select(default_value: default, data: { "blocks--theme-customizer-setting": name }) do
        SelectTrigger(start_slot: :selected, aria_labelledby: "#{@id}-#{name}", class: "bg-background") { SelectValue() }
        SelectContent(class: "max-h-80") do
          color_item("custom", t(".custom"), RAINBOW) if custom
          color_item("base", t(".base_primary"), "var(--foreground-intense)") if base
          colors.each { |color| color_item(color.to_s, color.to_s.titleize, PALETTE_500[color]) }
        end
      end
    end

    def color_item(value, label, swatch)
      SelectItem(value:, label:) do
        span(class: "border-border-strong/40 size-4 shrink-0 rounded-full border", style: "background: #{swatch}", data: { icon: "start" })
        plain label
      end
    end

    # The hex / oklch field shown while "Custom" is picked, with a native color picker
    def custom_color(name, fallback)
      div(hidden: true, class: "flex items-center gap-2", data: { "blocks--theme-customizer-target": "custom", setting: name }) do
        input(type: "color", value: fallback, aria_label: t(".pick_color"),
          class: "border-border-strong size-10 shrink-0 cursor-pointer rounded-md border bg-transparent p-1",
          data: { setting: name, action: "input->blocks--theme-customizer#customPicked" })
        Input(value: fallback, spellcheck: "false", autocomplete: "off", aria_label: t(".custom_color", setting: t(".#{name}")), class: "bg-background font-mono",
          data: { setting: name, action: "input->blocks--theme-customizer#customTyped" })
      end
    end

    def font_select
      Select(default_value: "system", data: { "blocks--theme-customizer-setting": "font" }) do
        SelectTrigger(start_slot: :typography, aria_labelledby: "#{@id}-font", class: "bg-background") { SelectValue() }
        SelectContent(class: "max-h-80") do
          FONTS.each { |value, label| SelectItem(value: value.to_s) { label } }
        end
      end
    end

    def radius_select
      Select(default_value: "large", data: { "blocks--theme-customizer-setting": "radius" }) do
        SelectTrigger(start_slot: :selected, aria_labelledby: "#{@id}-radius", class: "bg-background") { SelectValue() }
        SelectContent do
          RADII.each do |value, icon|
            SelectItem(value: value.to_s, label: t(".radii.#{value}")) do
              Icon(icon, data: { icon: "start" })
              plain t(".radii.#{value}")
            end
          end
        end
      end
    end

    def css_dialog
      Dialog do
        DialogTrigger { |trigger| Button(**trigger, class: "w-full") { t(".get_css") } }
        DialogContent(class: "w-180") do
          DialogHeader do
            DialogTitle { t(".css_title") }
            DialogDescription { t(".css_description") }
          end
          DialogBody do
            div(class: "relative") do
              pre(id: "#{@id}-css", class: "bg-background-muted text-foreground-emphasis max-h-96 overflow-auto rounded-lg p-4 pe-12 font-mono text-xs leading-relaxed break-all whitespace-pre-wrap",
                data: { slot: "theme-customizer-css", "blocks--theme-customizer-target": "css" }) { t(".no_changes") }
              CopyButton(target: "##{@id}-css", class: "absolute end-2 top-2")
            end
          end
        end
      end
    end
end
