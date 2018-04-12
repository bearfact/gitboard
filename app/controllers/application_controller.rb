class ApplicationController < ActionController::Base
  include Authenticable
  protect_from_forgery with: :null_session

  rescue_from ActionController::RoutingError, with: -> { render_404 }

  def render_404
    render "common/container"
  end
end
