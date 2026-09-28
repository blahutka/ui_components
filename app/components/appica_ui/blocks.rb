# Blocks: ready-made compositions of the UI primitives (a chat assistant, an order tracker…).
# Like AppicaUI it's a Phlex::Kit, so views that `include AppicaUI::Blocks` call them as tags:
#   ChatAssistant(title: "Appica Assistant") { ChatHeader(); ChatComposer() }
module AppicaUI::Blocks
  extend Phlex::Kit
end
