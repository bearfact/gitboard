class Repository < ActiveRecord::Base
  belongs_to :creator, :foreign_key => :user_id, :class_name => "User"
  has_many :repository_users
  has_many :users, :through => :repository_users
  has_many :issues_statuses
  accepts_nested_attributes_for :issues_statuses, allow_destroy: true

  validates_presence_of :owner, :name, :url
  validates_uniqueness_of :name, :scope => [:owner, :user_id]

  after_create :add_default_issues_statuses
  before_destroy :delete_orphaned_issues_statuses

  def destroy_if_no_users
    if repository_users.count == 0
      self.destroy
    end
  end

  def self.has_member?(owner, name, user)
    user.login == owner || RepositoryUser.joins(:repository).where({user_id: user.id, repositories: {owner: owner, name: name}}).count > 0
  end

  def self.create_or_assign(current_user, data)
    github = current_user.git_client
    is_a_member = current_user.login == data[:owner] || github.orgs.members.member?(data[:owner], current_user.login) || github.repos.collaborators.collaborator?(data[:owner], data[:name], current_user.login)
    repo = Repository.where({owner: data[:owner], name: data[:name]}).first || Repository.new(data)
    if !is_a_member
      repo.errors.add(:not_a_member, "You are not a member of this organization, please check you spelling or ask an admin to add you")
      repo
    else
      repo.user_id = current_user.id
      repo.repository_users << RepositoryUser.new({user_id: current_user.id})
      repo.save!
      repo
    end
  end

  private

  def add_default_issues_statuses
    repos = Repository.where({owner: owner})
    if (repos.count == 1)
      IssuesStatus.create({repository_id: self.id, position: 1, label: "", name: "Backlog"})
      IssuesStatus.create({repository_id: self.id, position: 2, label: "status:in_progress", name: "In Progress"})
      IssuesStatus.create({repository_id: self.id, position: 3, label: "status:qa", name: "Ready for QA"})
      IssuesStatus.create({repository_id: self.id, position: 4, label: "status:passed_qa", name: "Complete"})
    else
      repos[-2].issues_statuses.each do |is|
        IssuesStatus.create({repository_id: self.id, position: is.position, label: is.label, name: is.name})
      end
    end
  end

  def delete_orphaned_issues_statuses
    repos = Repository.where(name: name, owner: owner)
    if (repos.count == 1)
      IssuesStatus.delete_all "repository_id = #{id}"
    end
  end
end
