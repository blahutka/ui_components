// Registers the Stimulus controller of every block that ships one.
// Host app: `import "appica_ui/blocks"` from application.js (after `import "appica_ui"`).
import { application } from "controllers/application"

import ChatAssistantController from "appica_ui/blocks/chat_assistant/chat_assistant_controller"
import CommandMenuController from "appica_ui/blocks/command_menu/command_menu_controller"
import MusicPlayerController from "appica_ui/blocks/music_player/music_player_controller"
import NewsletterController from "appica_ui/blocks/newsletter/newsletter_controller"
import ThemeCustomizerController from "appica_ui/blocks/theme_customizer/theme_customizer_controller"
import TeamMembersController from "appica_ui/blocks/team_members/team_members_controller"
import TransactionsController from "appica_ui/blocks/transactions/transactions_controller"

application.register("appica-ui--blocks--chat-assistant", ChatAssistantController)
application.register("appica-ui--blocks--command-menu", CommandMenuController)
application.register("appica-ui--blocks--music-player", MusicPlayerController)
application.register("appica-ui--blocks--newsletter", NewsletterController)
application.register("appica-ui--blocks--theme-customizer", ThemeCustomizerController)
application.register("appica-ui--blocks--team-members", TeamMembersController)
application.register("appica-ui--blocks--transactions", TransactionsController)
