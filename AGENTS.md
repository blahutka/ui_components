# AGENTS.md

Guidance for AI agents (Claude Code, Codex, MCP servers…) working **with** or **on** this engine.

`ui_components` is a Rails engine: Appica UI's React components ported to **Phlex 2**, with
Appica's **Tailwind v4** classes and **Stimulus** controllers. Two Phlex kits:

- `AppicaUI` - primitives: `Button`, `Select`, `Dialog`, `Field`… (`app/components/appica_ui/`)
- `AppicaUI::Blocks` - compositions of primitives: `ReviewSummary`, `Transactions`, `ThemeCustomizer`… (`app/components/appica_ui/blocks/`)

## Start here: the component schemas

Don't read component source to learn how to use a component - read its schema.

1. **`app/components/schema.json`** - the index: every component's name, kit, one-line
   summary, parts and the path to its schema. Read it first.
2. **`app/components/<kit>/<folder>/<folder>.schema.json`** - one per component folder
   (a compound component and all its parts), e.g. `ui/select/select.schema.json`:

| Key | What it tells you |
|-----|-------------------|
| `description` | What the component is for, usually with a code sketch |
| `components` | The root and each part: `constant`, `props`, `parts`, `render_inside` |
| `components.*.props` | JSON-Schema-shaped: `properties` (with `enum`, `default`, `type`, `description`), `required`. `additionalProperties: true` - see *Props* below |
| `components.*.parts` / `render_inside` | The nesting: which parts go inside which root (e.g. `SelectItem` → inside `AppicaUI::Select`) |
| `examples` | Working calls - each Lookbook scenario's code and notes. Copy from here |
| `example_helpers` | Constants the examples use (`FRUIT_ITEMS = proc { … }`) so the code is complete |
| `docs` / `appica` | The Lookbook docs page (`docs/lookbook/…`) and Appica's original docs |

The schemas are **generated, never hand-edited** (see *Keeping the schemas current*).

## Using the components

```ruby
class ProfileCard < Phlex::HTML
  include AppicaUI        # Button(...), Select(...) { … }
  include AppicaUI::Blocks    # when you need a block

  def view_template
    Select(name: "plan", default_value: "pro") do
      SelectTrigger(aria_label: "Plan") { SelectValue(placeholder: "Pick a plan") }
      SelectContent do
        SelectItem(value: "free") { "Free" }
        SelectItem(value: "pro") { "Pro" }
      end
    end
  end
end
```

- **Props** are the declared `properties`. Any other keyword (`class:`, `id:`, `data:`,
  `aria_*`, `href:`…) goes to the component's root element. `class:` is merged with
  tailwind_merge, so your classes override the defaults.
- **Enums** (`variant:`, `size:`…) take the listed values as symbols; an unknown value silently
  falls back to the default - check `enum` in the schema.
- **Nesting matters**: a part outside its root raises `ArgumentError` ("… must be rendered inside
  Select"). Follow `render_inside`.
- **Render props**: a part whose block takes an argument yields its attributes instead of
  rendering its own element - `Toggle(value: "bold") { |toggle| Button(**toggle, variant: :ghost) { … } }`.
  Look for `{ |x| …(**x) }` in the examples.
- **Rails forms**: `form.ux.text_field :name`, `form.ux.select :plan, choices` etc. bind the
  components to a model (names, values, errors, validator constraints) - see
  `docs/lookbook/02_actions_&_inputs/form_builder.md.erb`. In Phlex views
  `include Phlex::Rails::Helpers::FormWith` and call `form.ux…` without `raw`.
- **Behaviour** lives in Stimulus controllers `appica-ui--<folder>` / `appica-ui--blocks--<folder>` (e.g.
  `appica-ui--select`), which emit events like `appica-ui--select:change` with `{ value }` - the component's
  description names them.
- **Theming**: colors, radius and font are CSS variables in `app/components/appica_ui/theme.css`.
  Override them in the host stylesheet **after** `@import ".../appica_ui/index.css"`; never edit or
  replace `theme.css` (it also maps each variable to its Tailwind utility). Generate overrides
  with the Lookbook **Theme customizer** block.

## Working on the engine

### Layout (sidecar files, one folder per component)

```
app/components/appica_ui/select/
  select.rb              # AppicaUI::Select (folders are collapsed: no extra namespace)
  select_item.rb         # parts: AppicaUI::SelectItem …
  select_controller.js   # Stimulus "appica-ui--select"
  select.css             # non-utility CSS, when needed
  select.locales.yml     # en / cs / de / ar strings, t(".key")
  select_preview.rb      # Lookbook scenarios (also the schema's examples)
  select.schema.json     # generated
docs/lookbook/NN_category/select.md.erb   # docs page
test/components/ui/select_test.rb         # Minitest
```

### Conventions

- Props: `prop :size, one_of(SIZES, :md), default: -> { :md }` (`AppicaUI::Props`, dry-initializer).
  Add `desc: "…"` to a prop and it shows up in the schema's `description`.
- The comment above a class is its documentation - it becomes the schema's `description`.
- Compound parts reach their root with `consume(:ui_select, component: "Select")`; roots share
  themselves with `provide`.
- Every string goes through `t(".key")` with all four locales (`test/components/locales_test.rb`
  checks parity).
- Previews: `phlex do … end` in a `AppicaUI::BasePreview` subclass with `@label` / `@logical_path`
  tags; scenario code is what agents and the Lookbook **Source** tab show - keep it idiomatic.
- The `default` (Usage) scenario exposes **every prop** of its component in the Lookbook
  Params form - `bin/rails "ui_components:preview_params[AppicaUI::Select]"` (from test/dummy) prints
  the tags, signature and call. Props that can't be a form field go in `UNLISTED_PROPS`;
  `test/components/preview_params_test.rb` enforces both.
- Enum params read their choices from the component: `select {{ choices_for AppicaUI::Select, :size }}` -
  never repeat a component's choices. Optional text props pass through `**given(title:)` so a
  blank field keeps the component's (often translated) default.
- Style: rubocop-rails-omakase, 37signals-flavoured Ruby - expanded conditionals over guard
  clauses (except a one-line early return), no blank line after `private` with its methods
  indented under it, private methods in call order. Minitest, no RSpec.

### Keeping the schemas current

```bash
cd test/dummy && bin/rails ui_components:schema
```

Run it after changing props, class comments or previews. It renders every Lookbook scenario
(recording which part renders inside which root) and rewrites every `*.schema.json` plus the
index; the output is deterministic. `test/components/schema_test.rb` fails when the committed
files are stale. The generator is `lib/ui_components/schema.rb`; `Klass.to_schema` returns one
component's props at runtime.

### Commands

```bash
bin/rails test                                   # full suite (includes schema freshness)
bundle exec rubocop                              # style
cd test/dummy && bin/dev -p 3047                 # Lookbook at http://localhost:3047/lookbook
cd test/dummy && bin/rails ui_components:schema  # regenerate schemas
```

Lookbook runs on port **3047** (3000 belongs to another project). New preview or locale files
need a server restart.
