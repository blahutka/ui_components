# UiComponents

[Appica UI](https://appica.dev/ui) components for Rails, rendered with **Phlex 2**, styled with
Appica's **Tailwind v4** classes and made interactive with **Stimulus**. Previews run in **Lookbook**.

```ruby
class FrameworkPicker < Phlex::HTML
  include UI

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

## Components

| Component | Parts | Appica docs |
|-----------|-------|-------------|
| Autocomplete | `Autocomplete`, `AutocompleteInput`, `AutocompleteContent`, `AutocompleteEmpty`, `AutocompleteList`, `AutocompleteItem`, `AutocompleteGroup`, `AutocompleteLabel`, `AutocompleteCollection` | [autocomplete](https://appica.dev/ui/components/react/autocomplete) |
| Button | `Button` (variants `primary`, `primary_outline`, `secondary`, `soft`, `outline`, `ghost`, `destructive`; sizes `sm`/`md`/`lg`; `icon: true`) | [button](https://appica.dev/ui/components/react/button) |
| Drawer | `Drawer`, `DrawerTrigger`, `DrawerContent`, `DrawerHeader`, `DrawerTitle`, `DrawerDescription`, `DrawerBody`, `DrawerFooter`, `DrawerClose` | [drawer](https://appica.dev/ui/components/react/drawer) |

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
on top/bottom drawers. JS events: `ui--drawer:open-change` and `ui--drawer:snap-point-change`.

## Layout

Each component lives in its own folder with everything it needs:

```
app/components/ui/autocomplete/
  autocomplete.rb, autocomplete_input.rb, …   # UI::Autocomplete, UI::AutocompleteInput, …
  autocomplete_controller.js                   # Stimulus controller "ui--autocomplete"
  autocomplete.css                             # non-utility CSS
  autocomplete_preview.rb                      # Lookbook scenarios
```

The folders are collapsed for Zeitwerk (no extra namespace), served by Propshaft and pinned
by the engine's importmap (`ui/...`). `app/components/ui/index.js` registers the controllers,
`app/components/ui/index.css` imports the Appica tokens (`theme.css`) and each component's CSS.

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
`<%= embed UI::DrawerPreview, :nested %>`. Components whose popups or panels need room in an
embed set `@display min_height …` on their preview class.

## Host app setup

```ruby
# Gemfile
gem "ui_components", path: "../ui_components"
```

```js
// app/javascript/application.js (after controllers/application exists)
import "ui"
```

```css
/* app/assets/tailwind/application.css — use the installed gem path (`bundle show ui_components`) */
@import "tailwindcss";
@import "<gem path>/app/components/ui/index.css";
@source "<gem path>/app/components";
```

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
- Previews live next to each component (`app/components/ui/<component>/*_preview.rb`).
- Use the **Theme** switcher in Lookbook's toolbar to preview dark mode; the preview layout is
  `test/dummy/app/views/layouts/component_preview.html.erb`.
- If styles look missing after adding new classes, check that the Tailwind watcher is running,
  or rebuild with `bin/rails tailwindcss:build` from `test/dummy`.
