// Registers the Stimulus controller of every component that ships one.
// Host app: `import "ui"` from application.js (after Stimulus is started).
import { application } from "controllers/application"

import AutocompleteController from "ui/autocomplete/autocomplete_controller"

application.register("ui--autocomplete", AutocompleteController)
