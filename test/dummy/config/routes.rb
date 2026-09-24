Rails.application.routes.draw do
  mount Lookbook::Engine, at: "/lookbook"
  root to: redirect("/lookbook")

  # Slow placeholder images for loading-state previews
  get "demo/images/:id" => "demo_images#show", as: :demo_image

  # Lookbook "Editor" panel: opens a project file in your editor (local requests, development only)
  get "editor/open" => "editor_openings#show", as: :editor_opening if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
end
