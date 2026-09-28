# UiComponents

[Appica UI](https://appica.dev/ui) components for Rails, rendered with **Phlex 2**, styled with
Appica's **Tailwind v4** classes and made interactive with **Stimulus**. Previews run in **Lookbook**.

```ruby
class FrameworkPicker < Phlex::HTML
  include AppicaUI

  def view_template
    Autocomplete(items: [ "Next.js", "Remix", "Astro" ]) do
      AutocompleteInput(placeholder: "Search a framework")
      AutocompleteContent do
        AutocompleteEmpty { "No frameworks found." }
        AutocompleteList do |item|
          AutocompleteItem(value: item) { item }
        end
      end
    end
  end
end
```

From ERB: `<%= render FrameworkPicker.new %>`.

## Rails forms

Use `form.ux` on the builder you already get from `form_with` or `fields_for`:

```erb
<%= form_with model: @user do |form| %>
  <%= form.ux.text_field :name, description: "As it appears on your profile" %>
  <%= form.ux.number_field :age, min: 0 %>
  <%= form.ux.select :locations, [["Prague", "prg"], ["Berlin", "ber"]],
        { prompt: "Pick cities" }, { multiple: true } %>
  <%= form.ux.text_area :bio %>
  <%= form.ux.radio_group :plan, [["Free", "free"], ["Pro", "pro"]] %>
  <%= form.ux.checkbox_group :interests, [["Design", "design"], ["Sales", "sales"]] %>
  <%= form.ux.combobox :skills, %w[Ruby Rails SQL], multiple: true %>
  <%= form.ux.range_field :experience %>
  <%= form.ux.otp_field :pin, length: 4 %>
  <%= form.ux.switch :newsletter %>
  <%= form.ux.check_box :terms_of_service %>
  <%= form.submit %>
<% end %>
```

Each helper renders a labelled Field, bound to Rails' names, IDs, values and model errors.
Unconditional presence, acceptance, length and numericality validators supply browser constraints;
explicit options override them. `label: false` renders only the control. Text helpers also include
email, password, telephone, URL and search inputs; `collection_select`, `collection_radio_buttons`
and `collection_check_boxes` keep Rails' signatures. Nested builders use their own object's labels,
validators and errors, with stable IDs per row.

Controllers receive ordinary strong parameters, so `User.new(user_params).save` works with Active
Record and `accepts_nested_attributes_for`. Check boxes and switches send Rails' hidden `"0"`;
multiple selections, check box groups and multiple comboboxes include a blank hidden entry so
clearing them submits the key; normalize with `compact_blank` in your model if needed.
See Lookbook's **Form builder** page for the full API and a working `/users/new` demo that saves
to the dummy app's SQLite database.

## Components

| Component | Parts | Appica docs |
|-----------|-------|-------------|
| Alert | `Alert`, `AlertIcon`, `AlertTitle`, `AlertDescription`, `AlertAction` (variants, `layout: :inline`, `dismissible:`, `persist_key:`) | [alert](https://appica.dev/ui/components/react/alert) |
| Alert Dialog | Dialog's parts as `AlertDialog*` (`role="alertdialog"`, no outside dismissal) | [alert-dialog](https://appica.dev/ui/components/react/alert-dialog) |
| Autocomplete | `Autocomplete`, `AutocompleteInput`, `AutocompleteContent`, `AutocompleteEmpty`, `AutocompleteList`, `AutocompleteItem`, `AutocompleteGroup`, `AutocompleteLabel`, `AutocompleteCollection` | [autocomplete](https://appica.dev/ui/components/react/autocomplete) |
| Breadcrumb | `Breadcrumb`, `BreadcrumbList`, `BreadcrumbItem`, `BreadcrumbLink` (`active:`, `disabled:`, render prop), `BreadcrumbSeparator`, `BreadcrumbEllipsis` | [breadcrumb](https://appica.dev/ui/components/react/breadcrumb) |
| Button | `Button` (variants `primary`, `primary_outline`, `secondary`, `soft`, `outline`, `ghost`, `destructive`; sizes `sm`/`md`/`lg`; `icon: true`) | [button](https://appica.dev/ui/components/react/button) |
| Button Group | `ButtonGroup` (shares `variant:`/`size:`/`icon:`/`disabled:` with its Buttons, horizontal/vertical) | [button-group](https://appica.dev/ui/components/react/button-group) |
| Checkbox | `Checkbox`, `CheckboxGroup` (native checkbox, indeterminate, `parent:` select-all, `unchecked_value:`) | [checkbox](https://appica.dev/ui/components/react/checkbox) |
| Chip | `Chip`, `ChipGroup` (Button palette, `dismissible:`, `href:`) | [chip](https://appica.dev/ui/components/react/chip) |
| Combobox | `Combobox`, `ComboboxInput`, `ComboboxChips`, `ComboboxTrigger`, `ComboboxValue`, `ComboboxContent`, `ComboboxList`, `ComboboxItem`, `ComboboxEmpty`, `ComboboxGroup`, `ComboboxLabel`, `ComboboxCollection`, `ComboboxSeparator` (`multiple:` chips, `creatable:`) | [combobox](https://appica.dev/ui/components/react/combobox) |
| Context Menu | `ContextMenu`, `ContextMenuTrigger` (right-click / long-press) + DropdownMenu's parts as `ContextMenu*` | [context-menu](https://appica.dev/ui/components/react/context-menu) |
| Copy Button | `CopyButton` (`value:` / `target:`, clipboard fallback) | [copy-button](https://appica.dev/ui/components/react/copy-button) |
| Dialog | `Dialog`, `DialogTrigger`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogDescription`, `DialogBody`, `DialogFooter`, `DialogClose` (native `<dialog>`, frame, nested, `default_open:`) | [dialog](https://appica.dev/ui/components/react/dialog) |
| Drawer | `Drawer`, `DrawerTrigger`, `DrawerContent`, `DrawerHeader`, `DrawerTitle`, `DrawerDescription`, `DrawerBody`, `DrawerFooter`, `DrawerClose` | [drawer](https://appica.dev/ui/components/react/drawer) |
| Dropdown Menu | `DropdownMenu`, `DropdownMenuTrigger`, `DropdownMenuContent`, `DropdownMenuItem`, `DropdownMenuCheckboxItem`, `DropdownMenuRadioGroup`, `DropdownMenuRadioItem`, `DropdownMenuLinkItem`, `DropdownMenuGroup`, `DropdownMenuGroupLabel`, `DropdownMenuSeparator`, `DropdownMenuSub`, `DropdownMenuSubTrigger`, `DropdownMenuSubContent` (top-layer, submenus, hover) | [dropdown-menu](https://appica.dev/ui/components/react/dropdown-menu) |
| Field | `Field`, `FieldLabel`, `FieldDescription`, `FieldError`, `Fieldset`, `FieldsetLegend` (native validation on submit/blur/change, server `error:`) | [field](https://appica.dev/ui/components/react/field) |
| Icon | `Icon(:name, size:, stroke_width:)` - the ~5,000 [Appica icons](https://appica.dev/ui/icons) by name | [icons](https://appica.dev/ui/icons) |
| Text field | `Input` (`:outline`/`:soft`, sizes, `start_slot:`/`end_slot:`, `clearable:`) | [input](https://appica.dev/ui/components/react/input) |
| Loader | `Loader` (`:bar`, `:dots`; SVG SMIL, no JS) | [loader](https://appica.dev/ui/components/react/loader) |
| Meter | `Meter`, `MeterLabel`, `MeterValue`, `MeterProgress` (`low:`/`high:`/`optimum:` status colors) | [meter](https://appica.dev/ui/components/react/meter) |
| Navigation | `Navigation`, `NavigationList`, `NavigationItem`, `NavigationLink` (`:pill`/`:line`/`:indicator`, `active_link:`, render prop) | [navigation](https://appica.dev/ui/components/react/navigation) |
| Navigation Menu | `NavigationMenu`, `NavigationMenuList`, `NavigationMenuItem`, `NavigationMenuTrigger`, `NavigationMenuIcon`, `NavigationMenuContent`, `NavigationMenuLink`, `NavigationMenuViewport` (top-layer morphing popup, backdrop, nested and inline submenus) | [navigation-menu](https://appica.dev/ui/components/react/navigation-menu) |
| Number Field | `NumberField` (steppers, Intl `format:`, hidden plain value) | [number-field](https://appica.dev/ui/components/react/number-field) |
| OTP Field | `OTPField`, `OTPFieldInput`, `OTPFieldSeparator` (paste / autofill, `mask:`, `auto_submit:`) | [otp-field](https://appica.dev/ui/components/react/otp-field) |
| Pagination | `Pagination`, `PaginationList`, `PaginationItem`, `PaginationLink`, `PaginationEllipsis`, `PaginationPages` (truncated range from `page:`/`pages:`) | [pagination](https://appica.dev/ui/components/react/pagination) |
| Popover | `Popover`, `PopoverTrigger` (`open_on_hover:`), `PopoverContent` (side / align / arrow), `PopoverTitle`, `PopoverDescription`, `PopoverClose` | [popover](https://appica.dev/ui/components/react/popover) |
| Preview Card | `PreviewCard`, `PreviewCardTrigger` (a link), `PreviewCardContent` (safe inside a paragraph) | [preview-card](https://appica.dev/ui/components/react/preview-card) |
| Progress | `Progress`, `ProgressLabel`, `ProgressValue` (`:bar`, `:circular`) | [progress](https://appica.dev/ui/components/react/progress) |
| Radio | `RadioGroup`, `Radio` (native radios, horizontal/vertical, `required:`) | [radio](https://appica.dev/ui/components/react/radio) |
| Rating | `Rating` (stars or any icon pair, fractions, read-only, form input) | [rating](https://appica.dev/ui/components/react/rating) |
| Select | `Select`, `SelectTrigger`, `SelectValue`, `SelectContent`, `SelectItem`, `SelectGroup`, `SelectGroupLabel`, `SelectSeparator` (top-layer popup, `multiple:`, `items:`) | [select](https://appica.dev/ui/components/react/select) |
| Separator | `Separator` (`:solid`, `:dashed`, `:dotted`, `:double`, `:gradient`, `:wave`, `:zigzag`) | [separator](https://appica.dev/ui/components/react/separator) |
| Skeleton | `Skeleton` (`:shimmer`, `:pulse`, `:none`; shaped and tinted by class) | [skeleton](https://appica.dev/ui/components/react/skeleton) |
| Slider | `Slider` (range, vertical, tooltip, Intl `format:`) | [slider](https://appica.dev/ui/components/react/slider) |
| Sparkline | `Sparkline`, `SparklineChart`, `SparklineValue`, `SparklineLabel` | [sparkline](https://appica.dev/ui/components/react/sparkline) |
| Spinner | `Spinner` (`:circular`, `:dots`, `:sparkle`; SVG SMIL, no JS) | [spinner](https://appica.dev/ui/components/react/spinner) |
| Switch | `Switch` (native checkbox with `role="switch"`, sizes, `unchecked_value:`) | [switch](https://appica.dev/ui/components/react/switch) |
| Tabs | `Tabs`, `TabsList`, `TabsTrigger`, `TabsContent` (`:pill`/`:line`, vertical, sliding indicator, icon tabs) | [tabs](https://appica.dev/ui/components/react/tabs) |
| Table of Contents | `Toc`, `TocList`, `TocItem`, `TocLink` (scroll-spy, `depth:`, `root_margin:`, `container:`) | [toc](https://appica.dev/ui/components/react/toc) |
| Textarea | `Textarea` (`rows:`, Input's variants, sizes, slots and `clearable:`) | [textarea](https://appica.dev/ui/components/react/textarea) |
| Thumbnail | `Thumbnail` (image with placeholder fallback, `:icon_*` tiles, sizes in em, `:circle`) | [thumbnail](https://appica.dev/ui/components/react/thumbnail) |
| Toggle | `Toggle`, `ToggleGroup` (render-prop onto a Button, single/multiple, roving focus, `name:`) | [toggle](https://appica.dev/ui/components/react/toggle) |
| Tooltip | `TooltipProvider`, `Tooltip` (`track_cursor_axis:`), `TooltipTrigger`, `TooltipContent` | [tooltip](https://appica.dev/ui/components/react/tooltip) |
| Toolbar | `Toolbar`, `ToolbarButton`, `ToolbarLink`, `ToolbarInput`, `ToolbarGroup`, `ToolbarSeparator` (roving focus, render props) | [toolbar](https://appica.dev/ui/components/react/toolbar) |

### Blocks

Higher-level compositions of the primitives live in `app/components/appica_ui/blocks/` (the `AppicaUI::Blocks` kit; add
`import "appica_ui/blocks"` next to `import "appica_ui"`):

| Block | Parts |
|-------|-------|
| Chat assistant | `ChatAssistant`, `ChatHeader`, `ChatMessages`, `ChatMessage`, `ChatStatus`, `ChatSuggestions`, `ChatSuggestion`, `ChatComposer` |
| Revenue summary | `RevenueSummary`, `RevenueMarkets`, `RevenueMarket`, `RevenueChart`, `RevenueStats`, `RevenueStat`, `CountryFlag` |
| Team members | `TeamMembers`, `TeamMemberList`, `TeamMember`, `TeamInvite` |
| Review summary | `ReviewSummary`, `ReviewBreakdown`, `ReviewHighlight` |
| Order tracker | `OrderTracker`, `OrderTimeline`, `OrderStep`, `OrderCourier` |
| Transactions | `Transactions`, `Transaction` |
| Product card | `ProductCard`, `ProductOptions`, `ProductAddToCart` |
| Music player | `MusicPlayer` |
| Command menu | `CommandMenu`, `CommandGroup`, `CommandItem` |
| Newsletter | `Newsletter`, `NewsletterPerk` |
| Theme customizer | `ThemeCustomizer` (+ `theme.js`: `overridesCss`, `applyTheme`, `watchStoredTheme`) |

### Render props

Where Appica takes `render={<Button />}`, the Phlex part yields its attributes to a block that
takes an argument, so you can put them on your own element:

```ruby
Drawer(side: :right) do
  DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "Open drawer" } }
  DrawerContent do
    DrawerHeader do
      DrawerTitle { "Notifications" }
      DrawerDescription { "Choose what you want to be notified about." }
    end
    DrawerBody { p { "…" } }
    DrawerFooter do
      DrawerClose { |close| Button(**close) { "Save" } }
      DrawerClose { |close| Button(**close, variant: :outline) { "Cancel" } }
    end
  end
end
```

Without an argument (`DrawerTrigger { "Open" }`) the part renders a plain `<button>`.
`DrawerContent` is a native `<dialog>` opened with `showModal()`, so it sits in the top layer
without a portal. Nest a `Drawer` inside `DrawerBody` for stacked drawers; `snap_points:` works
on top/bottom drawers. JS events: `appica-ui--drawer:open-change` and `appica-ui--drawer:snap-point-change`.

### Props

Components declare their props with `AppicaUI::Props` ([dry-initializer](https://hanakai.org/learn/dry/dry-initializer/v3.2)),
included in `AppicaUI::Base`. Declared props become instance variables (no public readers, so a prop called `title` or
`label` never hides a Phlex element); every other keyword - `class:`, `id:`, `data:`, `aria_*` - is collected in
`@attributes` for the root element.

```ruby
class AppicaUI::Badge < AppicaUI::Base
  prop :variant, one_of(VARIANTS, :primary), default: -> { :primary }  # enum with a fallback
  prop :size,    one_of(SIZES, :md), default: -> { :md }
  prop :as,      default: -> { nil }

  def view_template(&)
    span(**mix({ data: { slot: "badge", variant: @variant } }, @attributes.except(:class)), class: cn(…), &)
  end
end
```

`param` declares positional arguments (`Icon(:star)` → `param :name`), a proc after the name coerces the value, and
`as:` renames the ivar (`prop :as, as: :tag`). Defaults apply only when the keyword is missing, so values where an
explicit `nil` means "default" are resolved in a reader instead.

### Translations

Components translate with `t(".key")` (`AppicaUI::Localized`, in `AppicaUI::Base`). The scope comes from the component's folder -
`appica_ui/blocks/revenue_summary/*` → `ui_components.appica_ui.blocks.revenue_summary` - so every part of a compound component shares it
without declaring anything (`translation_scope "…"` overrides). The strings sit next to the component in one
`*.locales.yml` file with all languages side by side (`test/components/locales_test.rb` checks they define the same
keys); country names are shared in `app/components/appica_ui/countries.locales.yml`.

Translated defaults are declared on the props, and `translated` turns Symbol values into keys:

```ruby
prop :period, one_of(PERIODS, :other), default: -> { :other }
prop :title,  default: -> { t(".title.#{@period}") }   # "Monthly revenue" / "Měsíční tržby"
prop :label,  translated(".stats")                     # :orders → "Orders"; "Custom" stays
```

`format_money(amount, currency:)`, `format_count(value)` and `format_percent(value, sign:)` format in the current
locale (host apps need number formats for their locales, e.g. from rails-i18n). To override a string or add a
language, define the same keys in your app's locale files.

## Layout

Each component lives in its own folder with everything it needs:

```
app/components/appica_ui/autocomplete/
  autocomplete.rb, autocomplete_input.rb, …   # AppicaUI::Autocomplete, AppicaUI::AutocompleteInput, …
  autocomplete_controller.js                   # Stimulus controller "appica-ui--autocomplete"
  autocomplete.css                             # non-utility CSS
  autocomplete_preview.rb                      # Lookbook scenarios
```

The folders are collapsed for Zeitwerk (no extra namespace), served by Propshaft and pinned
by the engine's importmap (`ui/...`). `app/components/appica_ui/index.js` registers the controllers,
`app/components/appica_ui/index.css` imports the Appica tokens (`theme.css`) and each component's CSS.

## Schemas for LLMs and MCP servers

Every component folder has a generated `<folder>.schema.json` next to its code, and
`app/components/schema.json` indexes them (name, kit, one-line summary, parts, schema path).
An agent reads the index first, then the one schema it needs:

- `components` - the root and each part with `props` (JSON-Schema-shaped: `enum` from `one_of`,
  `default`, inferred `type`, `required`, `description` from `prop … desc:`), `parts` and
  `render_inside` (which part goes in which root);
- `description`, `docs` and `appica` - the class comment and links;
- `examples` + `example_helpers` - every Lookbook scenario's code and notes, with the preview
  constants it uses.

Nothing in them is written by hand: props come from the `prop` declarations, nesting is
recorded while rendering every Lookbook scenario, examples are the scenarios' source. After
changing props, class comments or previews, regenerate them (a test fails when they're stale):

```bash
cd test/dummy && bin/rails ui_components:schema
```

## Docs pages

Next to the previews, Lookbook shows a docs page per component under **Pages**, laid out like
Appica's docs (Usage, Examples, API reference, Accessibility) with live embeds and an
"On this page" navigation. They live in `docs/lookbook/`, in folders that mirror Appica's
categories:

```
docs/lookbook/
  01_overview.md.erb            # landing page
  02_actions_&_inputs/
    autocomplete.md.erb
    button.md.erb
  03_overlays/
    drawer.md.erb
```

Start a page with `<%= UiComponents::Lookbook::TableOfContents.call(page) %>` to get the
"On this page" box; it lists the `##` and `###` headings. Embed scenarios with
`<%= embed AppicaUI::DrawerPreview, :nested %>`. Components whose popups or panels need room in an
embed set `@display min_height …` on their preview class.

## Host app setup

```ruby
# Gemfile
gem "ui_components", path: "../ui_components"
```

```js
// app/javascript/application.js (after controllers/application exists)
import "appica_ui"
import "appica_ui/blocks"
```

```css
/* app/assets/tailwind/application.css — use the installed gem path (`bundle show ui_components`) */
@import "tailwindcss";
@import "<gem path>/app/components/appica_ui/index.css";
@source "<gem path>/app/components";
@source not "<gem path>/app/components/appica_ui/icon/icons";

/* Your theme: only the variables that differ, *after* the import above */
:root, .light { --primary: oklch(58.5% 0.233 277.117); --radius: 0.5rem; }
.dark { --primary: oklch(58.5% 0.233 277.117); --primary-foreground: oklch(1 0 0); }
```

### What the engine wires into a host

Two switches, both set in `config/application.rb`:

```ruby
config.ui_components.importmap = :auto  # pin the component JS only under Propshaft + importmap;
                                        # true always, false never
config.ui_components.lookbook  = false  # register the previews and docs pages in the host's Lookbook
```

`:auto` leaves Sprockets hosts alone: there the pins would point at assets the host never
precompiled. A host that embeds the components but serves their JavaScript some other way — an
engine shipping its own build, say — sets `importmap = false`.

View annotations (`<!-- BEGIN app/components/… -->` around every component) follow the host's own
`config.action_view.annotate_rendered_view_with_filenames`; the gem no longer turns it on.

### Theming

Generate the overrides with Lookbook's **Blocks → Theme customizer** (or appica.dev's "Get CSS
Code" - same output) and paste them into your stylesheet **after** `@import ".../appica_ui/index.css"`.
They list only the variables you changed. Don't paste them into, or in place of,
`appica_ui/theme.css`: that file holds every default token plus the `@theme inline` block that turns
`--primary` into `bg-primary`, `text-primary-foreground`…; without it those utilities aren't
generated at all and components lose their colors.

To let end users pick a theme at runtime, render `ThemeCustomizer()` and call
`watchStoredTheme()` from `blocks/theme_customizer/theme` on every page - it re-applies the stored
choice and follows changes made in other tabs.

## Development

```bash
bundle install
```

```bash
bin/rails test
```

### Running the dummy app (Lookbook)

`test/dummy` is a minimal Rails app that hosts the engine: Propshaft, Importmap + Stimulus,
Tailwind v4 (`tailwindcss-rails`) and Lookbook. It has no database, so there is nothing to migrate.

Start it from the engine root:

```bash
test/dummy/bin/dev
```

`bin/dev` builds Tailwind once (`bin/rails tailwindcss:build`), keeps a watcher running in the
background so class changes in `app/components/**/*.rb` are picked up, and starts Puma on port 3000.
The watcher stops when you stop the server with Ctrl-C.

Then open http://localhost:3000/lookbook (http://localhost:3000 redirects there).

Extra arguments go to `rails server`, so you can pick another port if 3000 is taken:

```bash
test/dummy/bin/dev -p 3047
```

To run the pieces separately, e.g. when using foreman with `test/dummy/Procfile.dev`:

```bash
cd test/dummy && bin/rails tailwindcss:build && bin/rails server
```

Live reload: open Lookbook pages refresh by themselves when you change a preview, a docs page, a
component (`.rb`, `.js`, `.css`) or when Tailwind rebuilds. This uses the `listen` gem and
Lookbook's websocket (`config.lookbook.live_updates` in `test/dummy/config/application.rb`).
New component folders are picked up on the next reload too, so a restart is only needed after
changing the engine, initializers, the Gemfile or anything else loaded once at boot.

Notes:
- Previews live next to each component (`app/components/appica_ui/<component>/*_preview.rb`).
- Lookbook's **display options** (⚙ in the preview toolbar) switch **Theme** (light/dark),
  **Locale** (English, Čeština, Deutsch, العربية - the preview renders in that `I18n.locale`, and
  right-to-left languages flip `dir`; see `test/dummy/config/initializers/lookbook.rb`) and
  **Viewport** (desktop/tablet/mobile). Tablet and mobile render the scenario inside an 820px /
  390px device frame, so breakpoints and media queries respond as on a real device. Touch input
  and `pointer: coarse` still need browser device emulation (open the preview in a new window).
  The preview layout is `test/dummy/app/views/layouts/component_preview.html.erb`.
- The inspector drawer has an **Editor** tab (hotkey `e`) with links that open the scenario's
  method, every file in the component's folder and its docs page in your editor. RubyMine by
  default (`x-mine://`, macOS); set `LOOKBOOK_EDITOR=idea|vscode|cursor|zed` (or a URL template
  with `%{file}` and `%{line}`) for another one. The links go through the dev server
  (`/editor/open`, development and local requests only, project files only), which hands the
  editor URL to macOS - so they also work in embedded browsers that won't follow `x-mine://`.
  See `test/dummy/app/lib/editor_link.rb`.
- If styles look missing after adding new classes, check that the Tailwind watcher is running,
  or rebuild with `bin/rails tailwindcss:build` from `test/dummy`.
