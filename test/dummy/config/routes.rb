Rails.application.routes.draw do
  mount Lookbook::Engine, at: "/lookbook"
  root to: redirect("/lookbook")

  # Slow placeholder images for loading-state previews
  get "demo/images/:id" => "demo_images#show", as: :demo_image

  get "up" => "rails/health#show", as: :rails_health_check
end
