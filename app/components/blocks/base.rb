# Base class for blocks: UI::Base's helpers (cn, provide/consume, defaults) plus both kits,
# so a block composes primitives the way application code does - Avatar(...), Button(...).
# Props are declared with UI::Props, from UI::Base (`prop :title, default: -> { "Revenue" }`).
class Blocks::Base < UI::Base
  include UI
  include Blocks
  include UI::ViewAnnotation
end
