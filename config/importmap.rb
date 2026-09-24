# Pins every component's sidecar JavaScript: app/components/ui/**/*.js → "ui/..."
pin_all_from UiComponents::Engine.root.join("app/components/ui"), under: "ui", to: "ui"

# Vendored third-party modules (vendor/javascript, see LICENSES.md there)
pin "embla-carousel", to: "embla-carousel.js"
pin "embla-carousel-autoplay", to: "embla-carousel-autoplay.js"
pin "embla-carousel-auto-scroll", to: "embla-carousel-auto-scroll.js"
pin "embla-carousel-fade", to: "embla-carousel-fade.js"
pin "embla-carousel-auto-height", to: "embla-carousel-auto-height.js"
pin "embla-carousel-wheel-gestures", to: "embla-carousel-wheel-gestures.js"
pin "wheel-gestures", to: "wheel-gestures.js"
