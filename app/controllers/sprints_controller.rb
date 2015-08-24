class SprintsController < ApplicationController

    def index
        sprints = Sprint.accessible_by_user(current_user)
        render json: sprints
    end

    def show
        sprint = Sprint.accessible_by_user(current_user).find(params[:id])
        render json: sprint
    end

    def create
        sprint = Sprint.new(sprint_parameters)
        if sprint.save
            render json: sprint
        else
            render json: sprint.errors, status: 422
        end
    end

    # def update
    #     repo = current_user.repositories.find(params[:id])
    #     #if(repo.user_id == current_user.id)
    #         repo.update(repository_parameters)
    #         if repo.save
    #             render json: repo
    #         else
    #             render json: repo.errors, status: 422
    #         end
    #     #else
    #     #    render json: "not authorized to perform that action", status: 403
    #     #end
    # end
    #
    # def destroy
    #     repo = Repository.find(params[:id])
    #     ru = repo.repository_users.where(:user_id => current_user.id).first
    #     if !ru.nil? && ru.destroy
    #         render json: repo
    #     else
    #         render json: repo, status: 500
    #     end
    # end

    private
    def sprint_parameters
        params.permit(:name, :due_date, :owner).merge!({ user_id: current_user.id })
    end

end
