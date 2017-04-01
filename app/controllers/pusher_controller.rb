class PusherController < ApplicationController
  def auth
    authed = false
    parts = params[:channel_name].to_s.split('_')
    Rails.logger.info "********** parts: #{parts.inspect}"
    if parts[0] == 'private-sprint'
      if Sprint.accessible_by_user(current_user).where(id: parts[1]).first
        authed = true
      end
    else
      if(Repository.has_member?(parts[1], parts[2], current_user))
        authed = true
      end
    end
    if authed
      auth = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      render json: auth
    else
      head :forbidden
    end
  end
end
