class AuthorizationController < WebsocketRails::BaseController
    def authorize_channels
        # The channel name will be passed inside the message Hash
        channel = WebsocketRails[message[:channel]].to_s
        split = message["channel"].to_s.split(':')
        if(Repository.has_member?(split[0], split[1], User.first))
            accept_channel
        else
            deny_channel({:message => 'authorization failed!'})
        end
    end
end
