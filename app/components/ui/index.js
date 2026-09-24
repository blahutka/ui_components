// Registers the Stimulus controller of every component that ships one.
// Host app: `import "ui"` from application.js (after Stimulus is started).
import { application } from "controllers/application"

import AutocompleteController from "ui/autocomplete/autocomplete_controller"
import AvatarController from "ui/avatar/avatar_controller"
import CarouselController from "ui/carousel/carousel_controller"
import DrawerController from "ui/drawer/drawer_controller"
import SparklineController from "ui/sparkline/sparkline_controller"

application.register("ui--autocomplete", AutocompleteController)
application.register("ui--avatar", AvatarController)
application.register("ui--carousel", CarouselController)
application.register("ui--drawer", DrawerController)
application.register("ui--sparkline", SparklineController)
