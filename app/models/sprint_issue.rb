class SprintIssue < ActiveRecord::Base
  attr_accessor :issue
  belongs_to :sprint
  #has_many :statuses

  validates_presence_of :sprint, :owner, :repository, :issue_number
  validates_numericality_of :priority_position
  validates_uniqueness_of :sprint_id, scope: [:issue_number, :owner, :repository]

  def self.accessible_by_user(user)
    SprintIssue.where(sprint_id: Sprint.accessible_by_user(user))
  end

  # def self.fetch_single_issue(sprint_issue_id, current_user)
  #     si = SprintIssue.accessible_by_user(current_user).find(sprint_issue_id)
  #     issue = current_user.git_client.issues.find si.owner, si.repository, si.issue_number, media: 'json'
  #     issue = Issue.transform(issue)
  # end


  def self.fetch_for_sprint(sprint_id, current_user)
    sprint = Sprint.accessible_by_user(current_user).find(sprint_id)
    repos = sprint.sprint_issues.map { |si| {owner: si.owner, name: si.repository} }.uniq
    issues_from_github = []
    issues_for_sprint = []
    all_accessible_repos = current_user.git_client.repos.list(per_page: 1000, page: 1).map { |repo| "#{repo.owner.login}/#{repo.name}" }
    repos.each do |repo|
      # checking if they have the repo registered which implies they have access, should just check for access
      #unless current_user.repositories.where(owner: repo[:owner], name: repo[:name]).first.nil?
      if all_accessible_repos.include?("#{repo[:owner]}/#{repo[:name]}")
        # which issues do I want from this repo
        issues_from_github = Issue.fetch_by_owner_and_repo(repo[:owner], repo[:name], current_user.git_client)
        sprint.sprint_issues.where(owner: repo[:owner], repository: repo[:name]).each do |si|
          matching_issues = issues_from_github.select{ |issue| si.issue_number == issue['number']}
          if matching_issues.any?
            issues_for_sprint << Issue.transform(matching_issues[0])
          end
        end
      end
    end
    issues_for_sprint
  end
end
