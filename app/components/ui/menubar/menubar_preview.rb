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
  ICON = { viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true" }.freeze

  ICONS = {
    file: "M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8zm0 0v5h5M9 13h6M9 17h4",
    pencil: "M4 20h4L18.5 9.5a2.8 2.8 0 0 0-4-4L4 16zm9.5-13.5 4 4",
    eye: "M2.5 12s3.5-7 9.5-7 9.5 7 9.5 7-3.5 7-9.5 7-9.5-7-9.5-7m9.5 3a3 3 0 1 0 0-6 3 3 0 0 0 0 6",
    file_plus: "M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8zm0 0v5h5M12 11v6m-3-3h6",
    folder: "M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z",
    download: "M12 4v11m0 0-4-4m4 4 4-4M5 20h14",
    undo: "M9 14 4 9l5-5M4 9h10a6 6 0 0 1 0 12h-3",
    redo: "m15 14 5-5-5-5m5 5H10a6 6 0 0 0 0 12h3",
    cut: "M6 9a3 3 0 1 0 0-6 3 3 0 0 0 0 6m0 12a3 3 0 1 0 0-6 3 3 0 0 0 0 6M20 4 8.1 15.9M14.5 14.5 20 20M8.1 8.1 12 12",
    copy: "M9 9h10v12H9zM5 15V3h10",
    paste: "M9 4h6v3H9zM7 5H5v16h14V5h-2",
    zoom_in: "M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14m10 3-5-5M11 8v6m-3-3h6",
    zoom_out: "M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14m10 3-5-5M8 11h6",
    maximize: "M4 9V4h5m6 0h5v5m0 6v5h-5m-6 0H4v-5",
    dashboard: "M5 4h4a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1m0 12h4a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-2a1 1 0 0 1 1-1m10-4h4a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1h-4a1 1 0 0 1-1-1v-6a1 1 0 0 1 1-1m0-8h4a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h-4a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1",
    users: "M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8m-7 10a7 7 0 0 1 14 0m1-10a3 3 0 1 0 0-6m5 16a6 6 0 0 0-4-5.6",
    settings: "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6m7.4-3a7.4 7.4 0 0 0-.1-1.2l2-1.6-2-3.4-2.4 1a7.5 7.5 0 0 0-2-1.2L14.5 3h-5l-.4 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.4 2 1.6a7.4 7.4 0 0 0 0 2.4l-2 1.6 2 3.4 2.4-1a7.5 7.5 0 0 0 2 1.2l.4 2.6h5l.4-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.4-2-1.6c.1-.4.1-.8.1-1.2"
  }.freeze

  # @label Application menu
  # A desktop-style command bar: File, Edit and View menus with shortcuts, separators,
  # a nested "Open recent" submenu and a disabled item.
  # @param variant [Symbol] select "Hover/active pill or animated underline" { choices: [pill, line] }
  # @param size [Symbol] select "Scales triggers, popups and items" { choices: [sm, md, lg] }
  def default(variant: :pill, size: :md)
    phlex do
      Menubar(variant:, size:, aria_label: "Application") do
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
        { "Overview" => [ :dashboard, [ "Summary", "Activity" ] ], "Projects" => [ :folder, [ "All projects", "New project", nil, "Archived" ] ],
          "Team" => [ :users, [ "Members", "Invitations" ] ], "Settings" => [ :settings, [ "General", "Billing" ] ] }.each do |label, (icon, items)|
          MenubarMenu do
            MenubarTrigger do
              svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[icon]) }
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
            svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:file]) }
            plain "File"
          end
          MenubarContent do
            MenubarItem do
              svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:file_plus]) }
              plain "New file"
              Kbd(size: :sm, class: "ms-auto") { "⌘N" }
            end
            MenubarItem do
              svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:folder]) }
              plain "Open…"
              Kbd(size: :sm, class: "ms-auto") { "⌘O" }
            end
            MenubarSeparator()
            MenubarItem do
              svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:download]) }
              plain "Save"
              Kbd(size: :sm, class: "ms-auto") { "⌘S" }
            end
          end
        end
        MenubarMenu do
          MenubarTrigger do
            svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:pencil]) }
            plain "Edit"
          end
          MenubarContent do
            { undo: "Undo", redo: "Redo", nil => nil, cut: "Cut", copy: "Copy", paste: "Paste" }.each do |icon, label|
              if label
                MenubarItem do
                  svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[icon]) }
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
            svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:eye]) }
            plain "View"
          end
          MenubarContent do
            { zoom_in: "Zoom in", zoom_out: "Zoom out" }.each do |icon, label|
              MenubarItem do
                svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[icon]) }
                plain label
              end
            end
            MenubarSeparator()
            MenubarItem do
              svg(**ICON, data: { icon: "start" }) { |s| s.path(d: ICONS[:maximize]) }
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
