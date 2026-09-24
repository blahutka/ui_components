# A text input that suggests matching options as you type.
#
# Compound component: the root holds the data (`items:`) and shared options
# (`size:`, `variant:`, `clearable:`, `icon:`, `grid:`); the parts compose the input
# and the filtered popup. Behaviour lives in the sidecar `autocomplete_controller.js`.
#
# @label Autocomplete
# @logical_path Actions & Inputs
# @component UI::Autocomplete
# @display width narrow
# @display min_height 22rem
class UI::AutocompletePreview < UI::BasePreview
  FRAMEWORKS = [ "Next.js", "Remix", "Astro", "Nuxt.js", "SvelteKit", "SolidStart", "Gatsby", "Vite" ].freeze

  COMMANDS = [
    { label: "Dashboard", icon: "M5 4h4a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1m0 12h4a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-2a1 1 0 0 1 1-1m10-4h4a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1h-4a1 1 0 0 1-1-1v-6a1 1 0 0 1 1-1m0-8h4a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h-4a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1" },
    { label: "Profile", icon: "M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8m-7 8a7 7 0 0 1 14 0" },
    { label: "Settings", icon: "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6m7.4-3a7.4 7.4 0 0 0-.1-1.2l2-1.6-2-3.4-2.4 1a7.5 7.5 0 0 0-2-1.2L14.5 3h-5l-.4 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.4 2 1.6a7.4 7.4 0 0 0 0 2.4l-2 1.6 2 3.4 2.4-1a7.5 7.5 0 0 0 2 1.2l.4 2.6h5l.4-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.4-2-1.6c.1-.4.1-.8.1-1.2" },
    { label: "Billing", icon: "M3 7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zm0 3h18M7 15h2" },
    { label: "Notifications", icon: "M6 8a6 6 0 1 1 12 0c0 7 3 9 3 9H3s3-2 3-9m4.3 13a1.9 1.9 0 0 0 3.4 0" },
    { label: "Messages", icon: "M4 6h16v12H4zm0 0 8 7 8-7" }
  ].freeze

  COUNTRIES = [
    { code: "AU", name: "Australia" }, { code: "BR", name: "Brazil" }, { code: "CA", name: "Canada" },
    { code: "FR", name: "France" }, { code: "DE", name: "Germany" }, { code: "IT", name: "Italy" },
    { code: "JP", name: "Japan" }, { code: "ES", name: "Spain" }, { code: "GB", name: "United Kingdom" },
    { code: "US", name: "United States" }
  ].freeze

  PRODUCE = [
    { value: "Fruits", items: [ "Apple", "Banana", "Cherry", "Grapefruit", "Mango", "Orange", "Strawberry" ] },
    { value: "Vegetables", items: [ "Broccoli", "Carrot", "Cucumber", "Lettuce", "Potato", "Spinach", "Tomato" ] },
    { value: "Herbs", items: [ "Basil", "Mint", "Oregano", "Parsley", "Rosemary", "Thyme" ] }
  ].freeze

  LIBRARIES = [ "React", "Vue", "Svelte", "Angular", "Solid", "Qwik", "Preact", "Lit" ].freeze

  # @label Usage
  # @param size [Symbol] select "Scales the input, popup radius and items together" { choices: [sm, md, lg] }
  # @param variant [Symbol] select "Bordered outline or filled soft field" { choices: [outline, soft] }
  # @param clearable [Boolean] toggle "Clear (✕) button once there's a value"
  # @param icon [Boolean] toggle "Chevron that toggles the popup"
  # @param placeholder text "Input placeholder, also used as the aria-label"
  def default(size: :md, variant: :outline, clearable: false, icon: false, placeholder: "Search a framework")
    phlex do
      Autocomplete(items: FRAMEWORKS, size:, variant:, clearable:, icon:) do
        AutocompleteInput(placeholder:, aria_label: placeholder)
        AutocompleteContent do
          AutocompleteEmpty { "No frameworks found." }
          AutocompleteList do |item|
            AutocompleteItem(value: item) { item }
          end
        end
      end
    end
  end

  # `variant:` switches the input between a bordered outline (default) and a filled soft field.
  def variants
    phlex do
      [ :outline, :soft ].each do |variant|
        Autocomplete(items: FRAMEWORKS, variant:) do
          AutocompleteInput(placeholder: "Search a framework", aria_label: "Search (#{variant})")
          AutocompleteContent do
            AutocompleteEmpty { "No frameworks found." }
            AutocompleteList { |item| AutocompleteItem(value: item) { item } }
          end
        end
      end
    end
  end

  # `size:` on the root scales the input, popup radius, and items together.
  def sizes
    phlex do
      [ :sm, :md, :lg ].each do |size|
        Autocomplete(items: FRAMEWORKS, size:) do
          AutocompleteInput(placeholder: "Search a framework", aria_label: "Search (#{size})")
          AutocompleteContent do
            AutocompleteEmpty { "No frameworks found." }
            AutocompleteList { |item| AutocompleteItem(value: item) { item } }
          end
        end
      end
    end
  end

  # @label Clearable & chevron
  # `clearable:` adds a clear (✕) button once there's a value, `icon:` a chevron that toggles the popup.
  def clearable
    phlex do
      Autocomplete(items: FRAMEWORKS, default_value: "Next.js", clearable: true, icon: true) do
        AutocompleteInput(placeholder: "Search a framework", aria_label: "Search a framework")
        AutocompleteContent do
          AutocompleteEmpty { "No frameworks found." }
          AutocompleteList { |item| AutocompleteItem(value: item) { item } }
        end
      end
    end
  end

  # @!group Object items
  #
  # @label Items with icons
  # Object items need `item_to_string_value:`. Mark a leading icon with `data-icon="start"`;
  # `start_slot: :selected_icon` mirrors the selected item's icon into the input.
  def with_icons
    phlex do
      Autocomplete(items: COMMANDS, item_to_string_value: :label, clearable: true, icon: true) do
        AutocompleteInput(placeholder: "Search commands", aria_label: "Search commands", start_slot: :selected_icon)
        AutocompleteContent do
          AutocompleteEmpty { "No commands found." }
          AutocompleteList do |command|
            AutocompleteItem(value: command) do
              svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5",
                  stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", data: { icon: "start" }) do |s|
                s.path(d: command[:icon])
              end
              plain command[:label]
            end
          end
        end
      end
    end
  end

  # @label Country search
  def country_search
    phlex do
      Autocomplete(items: COUNTRIES, item_to_string_value: :name, clearable: true, icon: true) do
        AutocompleteInput(placeholder: "Search a country", aria_label: "Search a country", start_slot: :selected_icon)
        AutocompleteContent do
          AutocompleteEmpty { "No countries found." }
          AutocompleteList do |country|
            AutocompleteItem(value: country) do
              flag = country[:code].chars.map { |char| (char.ord + 127_397).chr(Encoding::UTF_8) }.join
              span(class: "text-base leading-none", aria_hidden: "true", data: { icon: "start" }) { flag }
              plain country[:name]
            end
          end
        end
      end
    end
  end

  # @!endgroup

  # @label Grouped options
  # Grouped items (`{ value:, items: }`) render with AutocompleteGroup + AutocompleteLabel + AutocompleteCollection.
  def grouped
    phlex do
      Autocomplete(items: PRODUCE) do
        AutocompleteInput(placeholder: "Search produce", aria_label: "Search produce")
        AutocompleteContent do
          AutocompleteEmpty { "No produce found." }
          AutocompleteList do |group|
            AutocompleteGroup(items: group[:items]) do
              AutocompleteLabel { group[:value] }
              AutocompleteCollection do |item|
                AutocompleteItem(value: item) { item }
              end
            end
          end
        end
      end
    end
  end

  # @label Grid layout
  # `grid: true` lays options out in a grid (arrow keys move in two dimensions); `cols:` sets items per row.
  def grid
    phlex do
      Autocomplete(items: LIBRARIES, grid: true, icon: true) do
        AutocompleteInput(placeholder: "Search a library", aria_label: "Search a library")
        AutocompleteContent do
          AutocompleteEmpty { "No libraries found." }
          AutocompleteList(cols: 2) do |item|
            AutocompleteItem(value: item, class: "flex-1") { item }
          end
        end
      end
    end
  end

  # @label Static items & form
  # Static AutocompleteItem children work too. `name:` submits the typed/selected value with the form.
  def static_items
    phlex do
      form(action: "#", class: "flex flex-col gap-3") do
        Autocomplete(name: "framework") do
          AutocompleteInput(placeholder: "Pick a framework", aria_label: "Pick a framework")
          AutocompleteContent do
            AutocompleteEmpty { "No frameworks found." }
            AutocompleteList do
              AutocompleteItem(value: "Rails") { "Rails" }
              AutocompleteItem(value: "Hanami") { "Hanami" }
              AutocompleteItem(value: "Sinatra", disabled: true) { "Sinatra (disabled)" }
            end
          end
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl") do
        Autocomplete(items: [ "لوحة التحكم", "الملف الشخصي", "الإعدادات", "الفواتير" ], icon: true) do
          AutocompleteInput(placeholder: "ابحث عن أمر", aria_label: "ابحث عن أمر")
          AutocompleteContent do
            AutocompleteEmpty { "لا توجد نتائج." }
            AutocompleteList { |item| AutocompleteItem(value: item) { item } }
          end
        end
      end
    end
  end
end
