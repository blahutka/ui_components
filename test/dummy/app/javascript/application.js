import "controllers"
import "ui"
import "blocks"

// The Theme customizer's choices (Blocks::ThemeCustomizer) repaint every preview, live
import { watchStoredTheme } from "blocks/theme_customizer/theme"
watchStoredTheme()
