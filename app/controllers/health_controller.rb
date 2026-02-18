class HealthController < ActionController::API
  def show
    render plain: "OK", status: :ok
  end
end
