class RepositoryUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :repository

  validates_uniqueness_of :repository_id, :scope => [:user_id]

  after_destroy :notify_repository

  private

  def notify_repository
    repository.destroy_if_no_users
  end
end
