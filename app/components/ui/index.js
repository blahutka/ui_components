// Registers the Stimulus controller of every component that ships one.
// Host app: `import "ui"` from application.js (after Stimulus is started).
import { application } from "controllers/application"

import AlertController from "ui/alert/alert_controller"
import AutocompleteController from "ui/autocomplete/autocomplete_controller"
import AvatarController from "ui/avatar/avatar_controller"
import CarouselController from "ui/carousel/carousel_controller"
import CollapsibleController from "ui/collapsible/collapsible_controller"
import DrawerController from "ui/drawer/drawer_controller"
import MenubarController from "ui/menubar/menubar_controller"
import MeterController from "ui/meter/meter_controller"
import ProgressController from "ui/progress/progress_controller"
import RatingController from "ui/rating/rating_controller"
import ToasterController from "ui/toast/toaster_controller"
import "ui/toast/toast"
import SparklineController from "ui/sparkline/sparkline_controller"

application.register("ui--alert", AlertController)
application.register("ui--autocomplete", AutocompleteController)
application.register("ui--avatar", AvatarController)
application.register("ui--carousel", CarouselController)
application.register("ui--collapsible", CollapsibleController)
application.register("ui--drawer", DrawerController)
application.register("ui--menubar", MenubarController)
application.register("ui--meter", MeterController)
application.register("ui--progress", ProgressController)
application.register("ui--rating", RatingController)
application.register("ui--toaster", ToasterController)
application.register("ui--sparkline", SparklineController)
