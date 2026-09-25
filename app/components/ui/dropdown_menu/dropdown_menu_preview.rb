# A menu of actions opened from a button.
#
# @label Dropdown Menu
# @logical_path Menus
# @component UI::DropdownMenu
# @display width wide
# @display min_height 420px
class UI::DropdownMenuPreview < UI::BasePreview
  # @label Usage
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param open_on_hover [Boolean] toggle
  def default(size: :md, open_on_hover: false)
    phlex do
      DropdownMenu(size:, open_on_hover:) do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "Open" } }
        DropdownMenuContent do
          DropdownMenuGroup do
            DropdownMenuGroupLabel { "My Account" }
            DropdownMenuItem { "Profile" }
            DropdownMenuItem { "Billing" }
          end
          DropdownMenuSeparator()
          DropdownMenuGroup do
            DropdownMenuItem { "Team" }
            DropdownMenuItem { "Subscription" }
          end
        end
      end
    end
  end

  # @label Account menu
  # A header of plain markup, grouped items with count badges, a Settings submenu, a dark-mode
  # Switch that keeps the menu open, and sign out.
  def account
    phlex do
      DropdownMenu(data: { demo: "account" }) do
        DropdownMenuTrigger { |trigger| Button(**trigger) { Icon(:user_circle, data: { icon: "start" }); plain "My account" } }
        DropdownMenuContent(class: "min-w-64") do
          div(class: "flex gap-3 px-2.5 pt-2.5 pb-1.5") do
            Avatar(size: :sm) { AvatarFallback { "SJ" } }
            div(class: "min-w-0 flex-1") do
              p(class: "text-foreground-intense truncate text-sm font-semibold") { "Sarah Jenkins" }
              p(class: "text-foreground-muted truncate text-xs") { "sarah@appica.dev" }
            end
            Badge(variant: :secondary, size: :sm) { "User" }
          end
          DropdownMenuGroup do
            DropdownMenuGroupLabel { "Personal" }
            DropdownMenuItem { Icon(:user_circle, data: { icon: "start" }); plain "Profile" }
            DropdownMenuItem { Icon(:shopping_bag, data: { icon: "start" }); plain "My Orders"; Badge(variant: :outline, size: :sm, class: "ms-auto") { "2" } }
            DropdownMenuItem { Icon(:heart, data: { icon: "start" }); plain "Wishlist" }
            DropdownMenuItem { Icon(:message, data: { icon: "start" }); plain "Messages"; Badge(variant: :outline, size: :sm, class: "ms-auto") { "5" } }
          end
          DropdownMenuSeparator()
          DropdownMenuGroup do
            DropdownMenuGroupLabel { "Management" }
            DropdownMenuItem { Icon(:layout_dashboard, data: { icon: "start" }); plain "Dashboard" }
            DropdownMenuSub do
              DropdownMenuSubTrigger { Icon(:settings, data: { icon: "start" }); plain "Settings" }
              DropdownMenuSubContent do
                DropdownMenuItem { Icon(:id_badge_2, data: { icon: "start" }); plain "Personal Info" }
                DropdownMenuItem { Icon(:credit_card, data: { icon: "start" }); plain "Payments" }
                DropdownMenuItem { Icon(:map_pin, data: { icon: "start" }); plain "Addresses" }
              end
            end
            DropdownMenuItem { Icon(:bell_ringing, data: { icon: "start" }); plain "Notifications" }
            DropdownMenuItem(close_on_click: false, data: { demo: "dark" }) do
              Icon(:moon_stars, data: { icon: "start" })
              plain "Dark Mode"
              span(class: "ms-auto flex") { Switch(size: :sm, tabindex: "-1", aria_hidden: "true", class: "pointer-events-none", data: { demo: "switch" }) }
            end
          end
          DropdownMenuSeparator()
          DropdownMenuItem { Icon(:logout, data: { icon: "start" }); plain "Sign out" }
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const menu = document.querySelector("[data-demo=account]")
          menu.addEventListener("ui--dropdown-menu:select", ({ detail: { item } }) => {
            if (item.dataset.demo !== "dark") return
            const toggle = item.querySelector("[data-demo=switch]")
            toggle.checked = !toggle.checked
          })
        JS
      end
    end
  end

  # @label Icons, shortcuts & animated chevron
  # A Kbd pushed to the edge with `ms-auto`; the trigger's chevron flips while open.
  def shortcuts
    phlex do
      DropdownMenu do
        DropdownMenuTrigger do |trigger|
          Button(**trigger, variant: :outline, class: "group/trigger") do
            plain "Edit"
            Icon(:chevron_down, data: { icon: "end" }, class: "group-data-popup-open/trigger:rotate-180 motion-safe:transition-transform motion-safe:duration-200")
          end
        end
        DropdownMenuContent do
          { copy: [ "Copy", "⌘C" ], scissors: [ "Cut", "⌘X" ], clipboard: [ "Paste", "⌘V" ] }.each do |icon, (label, keys)|
            DropdownMenuItem { Icon(icon, data: { icon: "start" }); plain label; Kbd(size: :sm, class: "ms-auto") { keys } }
          end
          DropdownMenuSeparator()
          DropdownMenuItem(class: "text-error-emphasis") { Icon(:trash, data: { icon: "start" }); plain "Delete"; Kbd(size: :sm, class: "ms-auto") { "⌫" } }
        end
      end
    end
  end

  # @label Scrollable
  # A long menu scrolls within the viewport.
  def scrollable
    phlex do
      DropdownMenu do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "Pick a timezone" } }
        DropdownMenuContent(class: "max-h-72") do
          DropdownMenuGroupLabel { "Timezones" }
          [ "Pacific/Honolulu", "America/Anchorage", "America/Los_Angeles", "America/Denver", "America/Chicago", "America/New_York", "America/Sao_Paulo",
            "Europe/London", "Europe/Paris", "Europe/Prague", "Europe/Athens", "Asia/Dubai", "Asia/Kolkata", "Asia/Singapore", "Asia/Tokyo", "Australia/Sydney" ].each do |zone|
            DropdownMenuItem { zone.tr("_", " ") }
          end
        end
      end
    end
  end

  # @label Checkbox items
  # They keep the menu open; `checked-change` reports each toggle.
  def checkboxes
    phlex do
      DropdownMenu do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "View" } }
        DropdownMenuContent do
          DropdownMenuGroup do
            DropdownMenuGroupLabel { "Appearance" }
            DropdownMenuCheckboxItem(checked: true) { "Status bar" }
            DropdownMenuCheckboxItem { "Activity bar" }
            DropdownMenuCheckboxItem(disabled: true) { "Panel" }
          end
        end
      end
    end
  end

  # @label Radio items
  def radios
    phlex do
      DropdownMenu do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "Panel position" } }
        DropdownMenuContent do
          DropdownMenuRadioGroup(value: "bottom") do
            DropdownMenuGroupLabel { "Panel position" }
            DropdownMenuRadioItem(value: "top") { "Top" }
            DropdownMenuRadioItem(value: "bottom") { "Bottom" }
            DropdownMenuRadioItem(value: "right") { "Right" }
          end
        end
      end
    end
  end

  # Submenus open beside their trigger on hover, click or →.
  def submenus
    phlex do
      DropdownMenu do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "Share" } }
        DropdownMenuContent do
          DropdownMenuItem { Icon(:copy, data: { icon: "start" }); plain "Copy link" }
          DropdownMenuSub do
            DropdownMenuSubTrigger { Icon(:share, data: { icon: "start" }); plain "Share to" }
            DropdownMenuSubContent do
              DropdownMenuItem { "Email" }
              DropdownMenuItem { "Messages" }
              DropdownMenuSub do
                DropdownMenuSubTrigger { "More" }
                DropdownMenuSubContent do
                  DropdownMenuItem { "Slack" }
                  DropdownMenuItem { "Teams" }
                end
              end
            end
          end
          DropdownMenuItem { Icon(:download, data: { icon: "start" }); plain "Download" }
        end
      end
    end
  end

  # @label Open on hover
  def hover
    phlex do
      DropdownMenu(open_on_hover: true) do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :ghost) { plain "Products"; Icon(:chevron_down, data: { icon: "end" }) } }
        DropdownMenuContent do
          %w[ Analytics Automation Integrations ].each { |label| DropdownMenuItem { label } }
        end
      end
    end
  end

  # @label Link items
  # DropdownMenuLinkItem renders an <a>.
  def links
    phlex do
      DropdownMenu do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "Resources" } }
        DropdownMenuContent do
          DropdownMenuLinkItem(href: "#docs") { Icon(:file, data: { icon: "start" }); plain "Documentation" }
          DropdownMenuLinkItem(href: "https://appica.dev", target: "_blank", rel: "noopener") do
            Icon(:external_link, data: { icon: "start" })
            plain "Appica"
          end
        end
      end
    end
  end

  # `size:` scales the rows, labels and popup radius.
  def sizes
    phlex do
      div(class: "flex flex-wrap gap-3") do
        %i[ sm md lg ].each do |size|
          DropdownMenu(size:) do
            DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline, size:) { size.to_s } }
            DropdownMenuContent { %w[ Edit Duplicate Archive ].each { |label| DropdownMenuItem { label } } }
          end
        end
      end
    end
  end

  # @label Side & alignment
  # `side:` and `align:` place the popup; it flips when there's no room.
  def placement
    phlex do
      div(class: "flex flex-wrap gap-3") do
        [ [ :bottom, :start ], [ :bottom, :end ], [ :top, :center ], [ :inline_end, :start ] ].each do |side, align|
          DropdownMenu do
            DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline, size: :sm) { "#{side} / #{align}" } }
            DropdownMenuContent(side:, align:) { %w[ Edit Duplicate Archive ].each { |label| DropdownMenuItem { label } } }
          end
        end
      end
    end
  end

  # @label RTL
  # The popup aligns to the start edge and submenus open to the left.
  def rtl
    phlex do
      div(dir: "rtl") do
        DropdownMenu do
          DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "خيارات" } }
          DropdownMenuContent do
            DropdownMenuItem { "تعديل" }
            DropdownMenuSub do
              DropdownMenuSubTrigger { "مشاركة" }
              DropdownMenuSubContent { DropdownMenuItem { "البريد" }; DropdownMenuItem { "الرسائل" } }
            end
            DropdownMenuItem { "حذف" }
          end
        end
      end
    end
  end
end
