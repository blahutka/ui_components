# Pins every component's sidecar JavaScript: app/components/ui/**/*.js → "ui/..."
pin_all_from UiComponents::Engine.root.join("app/components/ui"), under: "ui", to: "ui"
