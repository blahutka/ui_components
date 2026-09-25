// Registers the Stimulus controller of every block that ships one.
// Host app: `import "blocks"` from application.js (after `import "ui"`).
import { application } from "controllers/application"

import ChatAssistantController from "blocks/chat_assistant/chat_assistant_controller"
import CommandMenuController from "blocks/command_menu/command_menu_controller"
import MusicPlayerController from "blocks/music_player/music_player_controller"
import NewsletterController from "blocks/newsletter/newsletter_controller"
import TeamMembersController from "blocks/team_members/team_members_controller"
import TransactionsController from "blocks/transactions/transactions_controller"

application.register("blocks--chat-assistant", ChatAssistantController)
application.register("blocks--command-menu", CommandMenuController)
application.register("blocks--music-player", MusicPlayerController)
application.register("blocks--newsletter", NewsletterController)
application.register("blocks--team-members", TeamMembersController)
application.register("blocks--transactions", TransactionsController)
