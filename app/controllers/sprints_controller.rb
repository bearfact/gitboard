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

  def update
    sprint = Sprint.accessible_by_user(current_user).find(params[:id])
    sprint.update(sprint_parameters)
    if sprint.save
      render json: sprint
    else
      render json: sprint.errors, status: 422
    end
  end

  def destroy
    sprint = Sprint.accessible_by_user(current_user).find(params[:id])
    if !sprint.nil? && sprint.destroy
      render json: sprint
    else
      render json: sprint, status: 422
    end
  end

  private

  def sprint_parameters
    params.permit(:name, :due_date, :owner, :status, issues_statuses_attributes: [:id, :name, :label, :position, :_destroy]).merge!({user_id: current_user.id})
  end
end
