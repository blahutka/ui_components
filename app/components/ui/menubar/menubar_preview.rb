# A bar of menus for an app's top-level commands.
#
# Menubar coordinates a row (or column) of MenubarMenus, sharing `variant:`, `size:` and
# `orientation:`. Each menu is a MenubarTrigger plus MenubarContent with items, groups,
# separators, checkbox / radio items and nested MenubarSubs.
#
# @label Menubar
# @logical_path Menus
# @component UI::Menubar
# @display width wide
# @display min_height 22rem
class UI::MenubarPreview < UI::BasePreview
  # @label Application menu
  # A desktop-style command bar: File, Edit and View menus with shortcuts, separators,
  # a nested "Open recent" submenu and a disabled item.
  # @param variant [Symbol] select "Hover/active pill or animated underline" {{ choices_for UI::Menubar, :variant }}
  # @param size [Symbol] select "Scales triggers, popups and items" {{ choices_for UI::Menubar, :size }}
  # @param orientation [Symbol] select {{ choices_for UI::Menubar, :orientation }}
  # @param loop_focus [Boolean] toggle
  # @param disabled [Boolean] toggle
  def default(variant: :pill, size: :md, orientation: :horizontal, loop_focus: true, disabled: false)
    phlex do
      Menubar(variant:, size:, orientation:, loop_focus:, disabled:, aria_label: "Application") do
        MenubarMenu do
          MenubarTrigger { "File" }
          MenubarContent do
            MenubarItem { plain "New file"; Kbd(size: :sm, class: "ms-auto") { "⌘N" } }
            MenubarItem { plain "Open…"; Kbd(size: :sm, class: "ms-auto") { "⌘O" } }
            MenubarSub do
              MenubarSubTrigger { "Open recent" }
              MenubarSubContent do
                MenubarItem { "project-alpha" }
                MenubarItem { "landing-page" }
                MenubarItem { "design-system" }
              end
            end
            MenubarSeparator()
            MenubarItem { plain "Save"; Kbd(size: :sm, class: "ms-auto") { "⌘S" } }
            MenubarItem { plain "Save as…"; Kbd(size: :sm, class: "ms-auto") { "⇧⌘S" } }
          end
        end
        MenubarMenu do
          MenubarTrigger { "Edit" }
          MenubarContent do
            MenubarItem { plain "Undo"; Kbd(size: :sm, class: "ms-auto") { "⌘Z" } }
            MenubarItem { plain "Redo"; Kbd(size: :sm, class: "ms-auto") { "⇧⌘Z" } }
            MenubarSeparator()
            MenubarItem { "Cut" }
            MenubarItem { "Copy" }
            MenubarItem { "Paste" }
          end
        end
        MenubarMenu do
          MenubarTrigger { "View" }
          MenubarContent do
            MenubarItem { "Zoom in" }
            MenubarItem { "Zoom out" }
            MenubarItem { "Reset zoom" }
            MenubarSeparator()
            MenubarItem(disabled: true) { "Enter full screen" }
          end
        end
      end
    end
  end

  # `variant: :pill` (default) gives each trigger a hover/active pill; `variant: :line` draws
  # an animated underline, closer to a classic desktop menu bar.
  def variants
    phlex do
      div(class: "flex flex-col items-center gap-8") do
        [ :pill, :line ].each do |variant|
          Menubar(variant:, aria_label: "#{variant.to_s.capitalize} menubar") do
            [ "File", "Edit", "View" ].each do |label|
              MenubarMenu do
                MenubarTrigger { label }
                MenubarContent do
                  MenubarItem { "Action one" }
                  MenubarItem { "Action two" }
                  MenubarItem { "Action three" }
                end
              end
            end
          end
        end
      end
    end
  end

  # `orientation: :vertical` stacks the menus into a sidebar; each menu opens to the
  # inline-end side. Triggers take a leading icon (`data: { icon: "start" }`).
  def vertical
    phlex do
      Menubar(orientation: :vertical, aria_label: "Workspace", class: "w-35") do
        { "Overview" => [ :layout_dashboard, [ "Summary", "Activity" ] ], "Projects" => [ :folder, [ "All projects", "New project", nil, "Archived" ] ],
          "Team" => [ :users, [ "Members", "Invitations" ] ], "Settings" => [ :settings, [ "General", "Billing" ] ] }.each do |label, (icon, items)|
          MenubarMenu do
            MenubarTrigger do
              Icon(icon, data: { icon: "start" })
              plain label
            end
            MenubarContent do
              items.each { |item| item ? MenubarItem { item } : MenubarSeparator() }
            end
          end
        end
      end
    end
  end

  # Nest a MenubarSub with its own MenubarSubTrigger and MenubarSubContent. It opens to the
  # side on hover or with the arrow keys, flipping near a screen edge.
  def submenus
    phlex do
      Menubar(aria_label: "Application") do
        MenubarMenu do
          MenubarTrigger { "File" }
          MenubarContent do
            MenubarItem { plain "New file"; Kbd(size: :sm, class: "ms-auto") { "⌘N" } }
            MenubarSub do
              MenubarSubTrigger { "Open recent" }
              MenubarSubContent do
                MenubarItem { "project-alpha" }
                MenubarItem { "landing-page" }
                MenubarItem { "design-system" }
                MenubarSeparator()
                MenubarItem { "Clear recent" }
              end
            end
            MenubarSeparator()
            MenubarItem { plain "Save"; Kbd(size: :sm, class: "ms-auto") { "⌘S" } }
          end
        end
        MenubarMenu do
          MenubarTrigger { "Share" }
          MenubarContent do
            MenubarItem { "Copy link" }
            MenubarSub do
              MenubarSubTrigger { "Export as" }
              MenubarSubContent do
                MenubarItem { "PDF" }
                MenubarItem { "PNG" }
                MenubarItem { "SVG" }
              end
            end
          end
        end
      end
    end
  end

  # @label Checkbox & radio items
  # MenubarCheckboxItem toggles; a MenubarRadioGroup of MenubarRadioItems picks one value.
  # Both keep the menu open and dispatch `ui--menubar:checked-change` / `value-change`.
  def selections
    phlex do
      Menubar(aria_label: "Editor") do
        MenubarMenu do
          MenubarTrigger { "View" }
          MenubarContent do
            MenubarGroup do
              MenubarGroupLabel { "Panels" }
              MenubarCheckboxItem(checked: true) { "Toolbar" }
              MenubarCheckboxItem { "Sidebar" }
            end
            MenubarSeparator()
            MenubarRadioGroup(value: "system") do
              MenubarGroupLabel { "Theme" }
              MenubarRadioItem(value: "light") { "Light" }
              MenubarRadioItem(value: "dark") { "Dark" }
              MenubarRadioItem(value: "system") { "System" }
            end
          end
        end
        MenubarMenu do
          MenubarTrigger { "Help" }
          MenubarContent do
            MenubarLinkItem(href: "https://appica.dev/ui/components/react/menubar", target: "_blank", rel: "noopener") { "Documentation" }
            MenubarItem { "Keyboard shortcuts" }
          end
        end
      end
    end
  end

  # @label Leading icons
  # A leading icon on `data: { icon: "start" }` works on triggers and items; a trailing Kbd
  # is pushed to the edge with `class: "ms-auto"`.
  def icons
    phlex do
      Menubar(aria_label: "Application") do
        MenubarMenu do
          MenubarTrigger do
            Icon(:file_text, data: { icon: "start" })
            plain "File"
          end
          MenubarContent do
            MenubarItem do
              Icon(:file_plus, data: { icon: "start" })
              plain "New file"
              Kbd(size: :sm, class: "ms-auto") { "⌘N" }
            end
            MenubarItem do
              Icon(:folder, data: { icon: "start" })
              plain "Open…"
              Kbd(size: :sm, class: "ms-auto") { "⌘O" }
            end
            MenubarSeparator()
            MenubarItem do
              Icon(:download, data: { icon: "start" })
              plain "Save"
              Kbd(size: :sm, class: "ms-auto") { "⌘S" }
            end
          end
        end
        MenubarMenu do
          MenubarTrigger do
            Icon(:pencil, data: { icon: "start" })
            plain "Edit"
          end
          MenubarContent do
            { arrow_back_up: "Undo", arrow_forward_up: "Redo", nil => nil, scissors: "Cut", copy: "Copy", clipboard: "Paste" }.each do |icon, label|
              if label
                MenubarItem do
                  Icon(icon, data: { icon: "start" })
                  plain label
                end
              else
                MenubarSeparator()
              end
            end
          end
        end
        MenubarMenu do
          MenubarTrigger do
            Icon(:eye, data: { icon: "start" })
            plain "View"
          end
          MenubarContent do
            { zoom_in: "Zoom in", zoom_out: "Zoom out" }.each do |icon, label|
              MenubarItem do
                Icon(icon, data: { icon: "start" })
                plain label
              end
            end
            MenubarSeparator()
            MenubarItem do
              Icon(:maximize, data: { icon: "start" })
              plain "Enter full screen"
            end
          end
        end
      end
    end
  end

  # @label RTL
  # The bar lays out from the right, arrow keys reverse, and popups and submenus open
  # towards the inline end.
  def rtl
    phlex do
      div(dir: "rtl") do
        Menubar(aria_label: "التطبيق") do
          { "ملف" => [ "ملف جديد", "فتح…", "حفظ" ], "تحرير" => [ "تراجع", "إعادة", "نسخ" ], "عرض" => [ "تكبير", "تصغير" ] }.each do |label, items|
            MenubarMenu do
              MenubarTrigger { label }
              MenubarContent do
                items.each { |item| MenubarItem { item } }
                if label == "ملف"
                  MenubarSub do
                    MenubarSubTrigger { "فتح الأخيرة" }
                    MenubarSubContent do
                      MenubarItem { "project-alpha" }
                      MenubarItem { "landing-page" }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
