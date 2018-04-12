class RepositoriesController < ApplicationController
  def index
    repositories = current_user.repositories.order(:name)
    render json: repositories #, each_serializer: RepositorySerializer
  end

  def show
    repository = current_user.repositories.where({owner: params[:owner_id], name: params[:id]}).first
    render json: repository #, serializer: RepositorySerializer
  end

  def create
    @repo = Repository.create_or_assign(current_user, repository_parameters)
    if @repo.errors.blank?
      render json: @repo
    else
      render json: @repo.errors, status: 422
    end
  end

  def update
    repo = current_user.repositories.find(params[:id])
    #if(repo.user_id == current_user.id)
    repo.update(repository_parameters)
    if repo.save
      render json: repo
    else
      render json: repo.errors, status: 422
    end
    #else
    #    render json: "not authorized to perform that action", status: 403
    #end
  end

  def destroy
    repo = Repository.find(params[:id])
    ru = repo.repository_users.where(:user_id => current_user.id).first
    if !ru.nil? && ru.destroy
      render json: repo
    else
      render json: repo, status: 500
    end
  end

  private

  def repository_parameters
    params.permit(:owner, :name, :description, :url, issues_statuses_attributes: [:id, :name, :label, :position, :_destroy]).merge!({user_id: current_user.id})
  end
end
