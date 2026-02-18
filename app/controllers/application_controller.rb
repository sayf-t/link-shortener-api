class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_link_not_found

  private

  def render_link_not_found(exception)
    render json: { error: "Link not found" }, status: :not_found
  end
end
