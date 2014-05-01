class UsersController < ApiController

    def index
        github = current_user.git_client
        me = nil
        begin
            users = github.orgs.members.list params[:owner_id]
        rescue
            me = github.users.get current_user.login
        end
        if me.nil?
            users_array = users.as_json
        else
            users_array  = Array.new
            users_array << me.to_hash
        end
        users_array << {login: "Unassigned", avatar_url: "/img/unassigned.jpg"}
        render json: users_array
    end

    def show
        user = User.find(params[:id])
        if !user.nil? && user.id == current_user.id
            render json: user
        else
            render json: nil, status: 404
        end
    end

    #def new
    #    @user = User.new
    #end

    def update
        user = User.find(params[:id])
        if !user.nil?
            user.issues_board_settings= user_parameters[:issues_board_settings]
            if user.save
                render json: user
            else
                render json: nil, status: 422
            end
        else
            render json: nil, status: 404
        end
    end

    private
    def user_parameters
        params.permit(:issues_board_settings => [:login, :milestone, :order])
    end

end
