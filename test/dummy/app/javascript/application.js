import "controllers"
import "appica_ui"
import "appica_ui/blocks"

// The Theme customizer's choices (AppicaUI::Blocks::ThemeCustomizer) repaint every preview, live
import { watchStoredTheme } from "appica_ui/blocks/theme_customizer/theme"
watchStoredTheme()
