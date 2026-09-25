// Registers the Stimulus controller of every block that ships one.
// Host app: `import "blocks"` from application.js (after `import "ui"`).
import { application } from "controllers/application"

import ChatAssistantController from "blocks/chat_assistant/chat_assistant_controller"
import TeamMembersController from "blocks/team_members/team_members_controller"
import TransactionsController from "blocks/transactions/transactions_controller"

application.register("blocks--chat-assistant", ChatAssistantController)
application.register("blocks--team-members", TeamMembersController)
application.register("blocks--transactions", TransactionsController)
