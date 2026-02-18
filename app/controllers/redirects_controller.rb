class RedirectsController < ApplicationController
  def show
    link = Link.find_by(short_code: params[:short_code])
    return render json: { error: "Short link not found" }, status: :not_found unless link

    if request.get?
      RecordClickJob.perform_later(
        link_id: link.id,
        ip: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current.iso8601
      )
    end

    redirect_to link.target_url, allow_other_host: true
  end
end
