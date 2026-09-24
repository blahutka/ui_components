# Serves a placeholder portrait after a delay, so previews can show loading states
class DemoImagesController < ApplicationController
  def show
    sleep params.fetch(:delay, 2.5).to_f.clamp(0, 5)
    send_file Rails.public_path.join("avatars", "#{params[:id].to_i.to_s.rjust(2, "0")}.png"),
      type: "image/png", disposition: "inline"
  end
end
