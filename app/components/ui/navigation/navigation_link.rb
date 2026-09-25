# A link of a Navigation. Current when its `value:` matches the root's `active_link:`, or when
# `active: true` (which wins); `disabled: true` dims it and takes it out of the tab order.
# `variant:` / `size:` / `orientation:` override the root's. A block taking an argument receives
# the attributes for your own element - a `<button>` for in-page selection, a router link:
#
#   NavigationLink(href: "/docs", value: "docs") { Icon(:book, data: { icon: "start" }); plain "Docs" }
#   NavigationLink(value: "billing") { |link| button(**link, type: "button") { "Billing" } }
#
# The :indicator variant slides a chevron in on hover / when current; `indicator:` replaces it
# (an icon name or a block).
class UI::NavigationLink < UI::Base
  # Current, pressed or active: the line stays drawn (Menubar::LINE draws it on hover / open)
  LINE_CURRENT = "data-active:data-[orientation=horizontal]:after:bg-size-[100%_2px] ltr:data-active:data-[orientation=horizontal]:after:bg-left rtl:data-active:data-[orientation=horizontal]:after:bg-right " \
    "data-pressed:data-[orientation=horizontal]:after:bg-size-[100%_2px] ltr:data-pressed:data-[orientation=horizontal]:after:bg-left rtl:data-pressed:data-[orientation=horizontal]:after:bg-right " \
    "data-active:data-[orientation=vertical]:after:bg-size-[2px_100%] data-active:data-[orientation=vertical]:after:[background-position-y:top] " \
    "data-pressed:data-[orientation=vertical]:after:bg-size-[2px_100%] data-pressed:data-[orientation=vertical]:after:[background-position-y:top]"

  INDICATOR = "max-w-full **:data-[slot=navigation-link-indicator]:inline-flex **:data-[slot=navigation-link-indicator]:items-center **:data-[slot=navigation-link-indicator]:justify-center " \
    "**:data-[slot=navigation-link-indicator]:overflow-hidden **:data-[slot=navigation-link-indicator]:shrink-0 **:data-[slot=navigation-link-indicator]:w-0 **:data-[slot=navigation-link-indicator]:opacity-0 " \
    "rtl:**:data-[slot=navigation-link-indicator]:rotate-180 **:data-[slot=navigation-link-indicator]:transition-[width,opacity] **:data-[slot=navigation-link-indicator]:duration-250 " \
    "**:data-[slot=navigation-link-indicator]:ease-out motion-reduce:**:data-[slot=navigation-link-indicator]:transition-none hover:**:data-[slot=navigation-link-indicator]:opacity-100 " \
    "focus-visible:**:data-[slot=navigation-link-indicator]:opacity-100 data-active:**:data-[slot=navigation-link-indicator]:opacity-100 " \
    "**:data-[slot=navigation-link-label]:flex-1 **:data-[slot=navigation-link-label]:min-w-0 **:data-[slot=navigation-link-label]:truncate"

  INDICATOR_SIZES = {
    sm: "text-xs [&_svg:not([class*='size-'])]:size-4 data-[orientation=horizontal]:py-2 data-[orientation=vertical]:py-1.5 hover:**:data-[slot=navigation-link-indicator]:w-4 focus-visible:**:data-[slot=navigation-link-indicator]:w-4 data-active:**:data-[slot=navigation-link-indicator]:w-4",
    md: "text-sm [&_svg:not([class*='size-'])]:size-4.5 data-[orientation=horizontal]:py-2.5 data-[orientation=vertical]:py-2 hover:**:data-[slot=navigation-link-indicator]:w-4.5 focus-visible:**:data-[slot=navigation-link-indicator]:w-4.5 data-active:**:data-[slot=navigation-link-indicator]:w-4.5",
    lg: "text-base [&_svg:not([class*='size-'])]:size-5 data-[orientation=horizontal]:py-3 data-[orientation=vertical]:py-2.5 hover:**:data-[slot=navigation-link-indicator]:w-5 focus-visible:**:data-[slot=navigation-link-indicator]:w-5 data-active:**:data-[slot=navigation-link-indicator]:w-5"
  }.freeze

  CHEVRON = "M5.558 3.558c.244-.244.641-.244.885 0l4 4c.244.244.244.641 0 .885l-4 4c-.244.244-.641.244-.885 0s-.244-.641 0-.885L9.115 8 5.558 4.442c-.244-.244-.244-.641 0-.885z"

  # A navigation link's look - shared with NavigationMenu's triggers and links
  def self.style(variant, size)
    style = case variant.to_sym
    when :line then [ UI::Menubar::LINE, LINE_CURRENT, UI::Menubar::LINE_SIZES[size.to_sym] ]
    when :indicator then [ INDICATOR, INDICATOR_SIZES[size.to_sym] ]
    else [ UI::Menubar::PILL, UI::Menubar::PILL_SIZES[size.to_sym] ]
    end
    [ UI::Menubar::ROW.sub("outline-hidden", "outline-none"), *style ].join(" ")
  end

  prop :value,       default: -> { nil }
  prop :active,      default: -> { nil }
  prop :disabled,    default: -> { false }
  prop :indicator,   default: -> { nil }
  prop :variant,     default: -> { nil }
  prop :size,        default: -> { nil }
  prop :orientation, default: -> { nil }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&block)
    attributes = mix(link_attributes, @attributes.except(:class)).merge(class: classes)

    if @render_prop
      yield attributes
    else
      a(**attributes) { variant == :indicator ? indicator_content(&block) : yield }
    end
  end

  private
    def navigation
      consume(:ui_navigation, component: "Navigation")
    end

    def variant = (@variant || navigation.variant).to_sym
    def size = (@size || navigation.size).to_sym
    def orientation = (@orientation || navigation.orientation).to_sym

    def current?
      @active.nil? ? navigation.active?(@value) : @active
    end

    def link_attributes
      {
        aria_current: ("page" if current?), aria_disabled: ("true" if @disabled), tabindex: ("-1" if @disabled),
        data: { slot: "navigation-link", orientation:, active: ("true" if current?), disabled: ("" if @disabled) }
      }.compact
    end

    def classes
      cn(self.class.style(variant, size), override: @attributes[:class])
    end

    def indicator_content
      span(data: { slot: "navigation-link-indicator" }, aria_hidden: "true") do
        case @indicator
        when Symbol then render UI::Icon.new(@indicator)
        when Proc then @indicator.call
        else svg(viewBox: "0 0 16 16", fill: "currentColor", aria_hidden: "true") { |s| s.path(d: CHEVRON) }
        end
      end
      span(data: { slot: "navigation-link-label" }) { yield }
    end
end
