// Registers the Stimulus controller of every component that ships one.
// Host app: `import "ui"` from application.js (after Stimulus is started).
import { application } from "controllers/application"

import AutocompleteController from "ui/autocomplete/autocomplete_controller"
import AvatarController from "ui/avatar/avatar_controller"
import DrawerController from "ui/drawer/drawer_controller"

application.register("ui--autocomplete", AutocompleteController)
application.register("ui--avatar", AvatarController)
application.register("ui--drawer", DrawerController)
