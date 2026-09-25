# Pick a value from a list you can filter by typing - single, multiple (chips) or creatable.
#
# @label Combobox
# @logical_path Actions & Inputs
# @component UI::Combobox
# @display width wide
# @display min_height 400px
class UI::ComboboxPreview < UI::BasePreview
  FRAMEWORKS = [ "Next.js", "Remix", "Astro", "Nuxt.js", "SvelteKit", "SolidStart" ].freeze

  # @label Usage
  # @param variant [Symbol] select { choices: [outline, soft] }
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param clearable [Boolean] toggle
  # @param icon [Boolean] toggle
  def default(variant: :outline, size: :md, clearable: false, icon: true)
    phlex do
      Combobox(items: FRAMEWORKS, variant:, size:, clearable:, icon:, name: "framework", class: "max-w-70") do
        ComboboxInput(placeholder: "Search a framework", aria_label: "Framework")
        ComboboxContent do
          ComboboxEmpty { "No frameworks found." }
          ComboboxList { |item| ComboboxItem(value: item) { item } }
        end
      end
    end
  end

  def variants
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-4") do
        %i[ outline soft ].each do |variant|
          Combobox(items: FRAMEWORKS, variant:) do
            ComboboxInput(placeholder: "Search a framework", aria_label: "Framework (#{variant})")
            ComboboxContent do
              ComboboxEmpty { "No frameworks found." }
              ComboboxList { |item| ComboboxItem(value: item) { item } }
            end
          end
        end
      end
    end
  end

  # @label Clearable & chevron
  # The chevron is on by default (`icon: false` to drop it); `clearable:` adds a ✕.
  def clearable
    phlex do
      Combobox(items: FRAMEWORKS, default_value: "Astro", clearable: true, class: "max-w-70") do
        ComboboxInput(placeholder: "Search a framework", aria_label: "Framework")
        ComboboxContent do
          ComboboxEmpty { "No frameworks found." }
          ComboboxList { |item| ComboboxItem(value: item) { item } }
        end
      end
    end
  end

  # @label Country select
  # Object items read through `item_to_string_value:` / `item_to_string_label:`;
  # `start_slot: :selected_icon` mirrors the chosen flag.
  def countries
    countries = %w[ au at be br ca cz fr de in it jp mx nl pl es se ch gb us ].map { |code| { code:, name: I18n.t("ui_components.countries.#{code}", default: code.upcase) } }
    phlex do
      Combobox(items: countries, item_to_string_value: :code, item_to_string_label: :name, default_value: "cz", name: "country", class: "max-w-70") do
        ComboboxInput(placeholder: "Search a country", start_slot: :selected_icon, aria_label: "Country")
        ComboboxContent do
          ComboboxEmpty { "No countries found." }
          ComboboxList(class: "max-h-64") do |country|
            ComboboxItem(value: country[:code], data: { label: country[:name] }) do
              CountryFlag(country[:code], class: "size-4.5 text-base", data: { icon: "start" })
              plain country[:name]
            end
          end
        end
      end
    end
  end

  # @label Input inside the popup
  # ComboboxTrigger + ComboboxValue make a select-style field; the search lives in the popup.
  def popup_search
    languages = %w[ Arabic Bengali Chinese Czech Danish Dutch English Finnish French German Greek Hebrew Hindi Hungarian Italian Japanese Korean Polish Portuguese Spanish Swedish ]
    phlex do
      Combobox(items: languages, icon: false, class: "max-w-70") do
        ComboboxTrigger(aria_label: "Select a language") { ComboboxValue(placeholder: "Select a language") }
        ComboboxContent do
          div(class: "px-2 pb-2") { ComboboxInput(placeholder: "Search a language", aria_label: "Search a language") }
          ComboboxEmpty { "No languages found." }
          ComboboxList(class: "max-h-64") { |item| ComboboxItem(value: item) { item } }
        end
      end
    end
  end

  # @label Grouped options
  def grouped
    groups = [ { value: "Fruits", items: %w[ Apple Banana Orange ] }, { value: "Vegetables", items: %w[ Carrot Potato Tomato ] } ]
    phlex do
      Combobox(items: groups, class: "max-w-70") do
        ComboboxInput(placeholder: "Search food", aria_label: "Food")
        ComboboxContent do
          ComboboxEmpty { "No food found." }
          ComboboxList do |group|
            ComboboxGroup(items: group[:items]) do
              ComboboxLabel { group[:value] }
              ComboboxCollection { |item| ComboboxItem(value: item) { item } }
            end
          end
        end
      end
    end
  end

  # @label Multiple selection
  # ComboboxChips shows each value as a chip; Backspace in the empty field removes the last.
  def multiple
    phlex do
      Combobox(items: FRAMEWORKS + %w[ Gatsby Vite ], multiple: true, default_value: [ "Next.js", "Astro" ], name: "frameworks", clearable: true, class: "max-w-70") do
        ComboboxChips(placeholder: "Add frameworks", aria_label: "Frameworks")
        ComboboxContent do
          ComboboxEmpty { "No frameworks found." }
          ComboboxList { |item| ComboboxItem(value: item) { item } }
        end
      end
    end
  end

  # `creatable: true` offers the query as a new entry when nothing matches exactly
  # (`ui--combobox:create` fires with it).
  def creatable
    phlex do
      Combobox(items: [ "bug", "documentation", "enhancement", "help wanted", "good first issue" ], multiple: true, creatable: true, class: "max-w-70") do
        ComboboxChips(placeholder: "Add labels…", aria_label: "Labels")
        ComboboxContent do
          ComboboxEmpty { "No labels found." }
          ComboboxList { |item| ComboboxItem(value: item) { item } }
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl", class: "w-full max-w-70") do
        Combobox(items: %w[ تفاح موز برتقال فراولة ], clearable: true) do
          ComboboxInput(placeholder: "ابحث عن فاكهة", aria_label: "فاكهة")
          ComboboxContent do
            ComboboxEmpty { "لا توجد نتائج." }
            ComboboxList { |item| ComboboxItem(value: item) { item } }
          end
        end
      end
    end
  end
end
