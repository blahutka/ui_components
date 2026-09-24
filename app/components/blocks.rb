# Blocks: ready-made compositions of the UI primitives (a chat assistant, an order tracker…).
# Like UI it's a Phlex::Kit, so views that `include Blocks` call them as tags:
#   ChatAssistant(title: "Appica Assistant") { ChatHeader(); ChatComposer() }
module Blocks
  extend Phlex::Kit
end
