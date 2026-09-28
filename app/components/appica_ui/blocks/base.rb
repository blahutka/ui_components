# Base class for blocks: AppicaUI::Base's helpers (cn, provide/consume, defaults) plus both kits,
# so a block composes primitives the way application code does - Avatar(...), Button(...).
# Props are declared with AppicaUI::Props, from AppicaUI::Base (`prop :title, default: -> { "Revenue" }`).
class AppicaUI::Blocks::Base < AppicaUI::Base
  include AppicaUI
  include AppicaUI::Blocks
  include AppicaUI::ViewAnnotation
end
