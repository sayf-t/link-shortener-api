class RedirectsController < ApplicationController
  def show
    link = Link.find_by(short_code: params[:short_code])
    return render json: { error: "Short link not found" }, status: :not_found unless link

    if request.get?
      Clicks::RecorderService.call(
        link: link,
        ip: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    redirect_to link.target_url, allow_other_host: true
  end
end
