// Registers the Stimulus controller of every component that ships one.
// Host app: `import "appica_ui"` from application.js (after Stimulus is started).
import { application } from "controllers/application"

import AlertController from "appica_ui/alert/alert_controller"
import AutocompleteController from "appica_ui/autocomplete/autocomplete_controller"
import AvatarController from "appica_ui/avatar/avatar_controller"
import CheckboxController from "appica_ui/checkbox/checkbox_controller"
import CheckboxGroupController from "appica_ui/checkbox/checkbox_group_controller"
import CarouselController from "appica_ui/carousel/carousel_controller"
import ChipController from "appica_ui/chip/chip_controller"
import ChipGroupController from "appica_ui/chip/chip_group_controller"
import ToggleController from "appica_ui/toggle/toggle_controller"
import ToggleGroupController from "appica_ui/toggle/toggle_group_controller"
import ComboboxController from "appica_ui/combobox/combobox_controller"
import CollapsibleController from "appica_ui/collapsible/collapsible_controller"
import ContextMenuController from "appica_ui/context_menu/context_menu_controller"
import CopyButtonController from "appica_ui/copy_button/copy_button_controller"
import DropdownMenuController from "appica_ui/dropdown_menu/dropdown_menu_controller"
import DialogController from "appica_ui/dialog/dialog_controller"
import DrawerController from "appica_ui/drawer/drawer_controller"
import FieldController from "appica_ui/field/field_controller"
import InputController from "appica_ui/input/input_controller"
import MenubarController from "appica_ui/menubar/menubar_controller"
import MeterController from "appica_ui/meter/meter_controller"
import NavigationMenuController from "appica_ui/navigation_menu/navigation_menu_controller"
import NumberFieldController from "appica_ui/number_field/number_field_controller"
import SelectController from "appica_ui/select/select_controller"
import SliderController from "appica_ui/slider/slider_controller"
import OTPFieldController from "appica_ui/otp_field/otp_field_controller"
import PopoverController from "appica_ui/popover/popover_controller"
import ProgressController from "appica_ui/progress/progress_controller"
import RatingController from "appica_ui/rating/rating_controller"
import TabsController from "appica_ui/tabs/tabs_controller"
import TocController from "appica_ui/toc/toc_controller"
import ToolbarController from "appica_ui/toolbar/toolbar_controller"
import ToasterController from "appica_ui/toast/toaster_controller"
import "appica_ui/toast/toast"
import SparklineController from "appica_ui/sparkline/sparkline_controller"

application.register("appica-ui--alert", AlertController)
application.register("appica-ui--autocomplete", AutocompleteController)
application.register("appica-ui--avatar", AvatarController)
application.register("appica-ui--checkbox", CheckboxController)
application.register("appica-ui--checkbox-group", CheckboxGroupController)
application.register("appica-ui--carousel", CarouselController)
application.register("appica-ui--chip", ChipController)
application.register("appica-ui--chip-group", ChipGroupController)
application.register("appica-ui--toggle", ToggleController)
application.register("appica-ui--toggle-group", ToggleGroupController)
application.register("appica-ui--combobox", ComboboxController)
application.register("appica-ui--collapsible", CollapsibleController)
application.register("appica-ui--context-menu", ContextMenuController)
application.register("appica-ui--copy-button", CopyButtonController)
application.register("appica-ui--dropdown-menu", DropdownMenuController)
application.register("appica-ui--dialog", DialogController)
application.register("appica-ui--drawer", DrawerController)
application.register("appica-ui--field", FieldController)
application.register("appica-ui--input", InputController)
application.register("appica-ui--menubar", MenubarController)
application.register("appica-ui--meter", MeterController)
application.register("appica-ui--navigation-menu", NavigationMenuController)
application.register("appica-ui--number-field", NumberFieldController)
application.register("appica-ui--select", SelectController)
application.register("appica-ui--slider", SliderController)
application.register("appica-ui--otp-field", OTPFieldController)
application.register("appica-ui--popover", PopoverController)
application.register("appica-ui--progress", ProgressController)
application.register("appica-ui--rating", RatingController)
application.register("appica-ui--tabs", TabsController)
application.register("appica-ui--toc", TocController)
application.register("appica-ui--toolbar", ToolbarController)
application.register("appica-ui--toaster", ToasterController)
application.register("appica-ui--sparkline", SparklineController)
