class RedirectsController < ApplicationController
  def show
    link = Link.find_by(short_code: params[:short_code])
    return render json: { error: "Short link not found" }, status: :not_found unless link

    return render json: { error: "Invalid redirect URL" }, status: :unprocessable_content unless valid_redirect_url?(link.target_url)

    if request.request_method == "GET"
      RecordClickJob.perform_later(
        link_id: link.id,
        ip: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current.iso8601
      )
    end

    head :found, location: link.target_url
  end

  private

  def valid_redirect_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError, TypeError
    false
  end
end
