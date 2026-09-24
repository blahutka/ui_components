# Opens a project file in your editor for the Lookbook "Editor" panel. The server runs on your
# machine, so it can hand the editor URL (x-mine://…) to the OS - which works from any browser,
# including embedded ones that won't follow custom URL schemes themselves.
#
# Development only (see config/routes.rb), local requests only, files inside the project only.
class EditorOpeningsController < ApplicationController
  before_action :require_local_request

  def show
    if EditorLink.openable?(params[:file])
      Process.detach(Process.spawn(opener, EditorLink.url(params[:file], params[:line]), out: File::NULL, err: File::NULL))
      head :no_content
    else
      head :not_found
    end
  end

  private
    def require_local_request
      head :forbidden unless request.local?
    end

    def opener
      RbConfig::CONFIG["host_os"].include?("darwin") ? "open" : "xdg-open"
    end
end
