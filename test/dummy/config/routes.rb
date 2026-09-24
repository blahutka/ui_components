Rails.application.routes.draw do
  mount Lookbook::Engine, at: "/lookbook"
  root to: redirect("/lookbook")

  get "up" => "rails/health#show", as: :rails_health_check
end
