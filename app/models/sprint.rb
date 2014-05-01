class Sprint < ActiveRecord::Base
  belongs_to :creator, foreign_key: :user_id, class_name: 'User'
  has_many :sprint_issues, dependent: :destroy
  has_many :issues_statuses, foreign_key: :sprint_id, dependent: :destroy
  accepts_nested_attributes_for :issues_statuses, allow_destroy: true

  validates_presence_of :user_id, :owner, :name
  validates_uniqueness_of :name, scope: [:owner]

  after_create :add_default_issues_statuses
  before_destroy :delete_orphaned_issues_statuses

  enum status: {
    active: 1,
    inactive: 2,
    complete: 3
  }

  def self.accessible_by_user(user)
    github = user.git_client
    owners = github.orgs.list auto_pagination: true
    owners = owners.collect(&:login)
    owners << user.login
    Sprint.where(owner: owners)
  end

  private

  def add_default_issues_statuses
    sprints = Sprint.where({owner: owner})
    if(sprints.count == 1)
      IssuesStatus.create({sprint_id: self.id, position: 1, label: "", name: "Backlog"})
      IssuesStatus.create({sprint_id: self.id, position: 2, label: "status:in_progress", name: "In Progress"})
      IssuesStatus.create({sprint_id: self.id, position: 3, label: "status:qa", name: "Ready for QA"})
      IssuesStatus.create({sprint_id: self.id, position: 4, label: "status:passed_qa", name: "Complete"})
    else
      sprints[-2].issues_statuses.each do |is|
        IssuesStatus.create({sprint_id: self.id, position: is.position, label: is.label, name: is.name})
      end
    end
  end

  def delete_orphaned_issues_statuses
    repos = Repository.where(name: name, owner: owner)
    IssuesStatus.delete_all "sprint_id = #{id}" if repos.count == 1
  end

end
