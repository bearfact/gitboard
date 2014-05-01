class AuthorizationController < WebsocketRails::BaseController
    def authorize_channels
        # The channel name will be passed inside the message Hash
        channel = WebsocketRails[message[:channel]].to_s
        split = message["channel"].to_s.split(':')
        if split[0] == "sprint"
          if Sprint.accessible_by_user(current_user).where(id: split[1]).first
            accept_channel
          else
            deny_channel({:message => 'authorization failed!'})
          end
        else
          if(Repository.has_member?(split[0], split[1], current_user))
              accept_channel
          else
              deny_channel({:message => 'authorization failed!'})
          end
        end
    end
end
