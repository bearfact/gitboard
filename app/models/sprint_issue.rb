class SprintIssue < ActiveRecord::Base
  attr_accessor :issue
  belongs_to :sprint
  has_many :statuses

  validates_presence_of :sprint, :owner, :repository, :issue_number
  validates_numericality_of :priority_position
  validates_uniqueness_of :sprint_id, scope: [:issue_number, :owner, :repository]

  def self.accessible_by_user(user)
    SprintIssue.where(sprint_id: Sprint.accessible_by_user(user))
  end

  def self.fetch_single_issue(sprint_issue_id, current_user)
      si = SprintIssue.accessible_by_user(current_user).find(sprint_issue_id)
      issue = current_user.github.issues.find si.owner, si.repository, si.issue_number, media: 'json'
      issue['priority_position'] = si.priority_position
      issue["sprint_issue_id"] = si.id
      issue = add_caluclated_value(issue.to_hash, si.sprint.issues_statuses, si.owner, si.repository)
  end


  def self.fetch_for_sprint(sprint_id, current_user)
    sprint = Sprint.accessible_by_user(current_user).find(sprint_id)
    repos = sprint.sprint_issues.map { |si| {owner: si.owner, name: si.repository} }.uniq
    issues_from_github = []
    issues_for_sprint = []
    repos.each do |repo|
      # checking if they have the repo registered which implies they have access, should just check for access
      unless current_user.repositories.where(owner: repo[:owner], name: repo[:name]).first.nil?
        # which issues do I want from this repo
        issues_from_github = Issue.fetch_by_owner_and_repo(repo[:owner], repo[:name], current_user.git_client)
        sprint.sprint_issues.where(owner: repo[:owner], repository: repo[:name]).each do |si|
          matching_issues = issues_from_github.select{ |issue| si.issue_number == issue['number']}
          if matching_issues.any?
            #si.issue = matching_issues[0]
            issue = matching_issues[0]
            issue['priority_position'] = si.priority_position
            issue["sprint_issue_id"] = si.id
            issue["sprint"] = si.sprint
            issue["points"] = si.points
            issue = add_caluclated_value(issue.to_hash, si.sprint.issues_statuses, si.owner, si.repository)
            issues_for_sprint << issue
          end
        end
      end
    end
    issues_for_sprint
  end

  private
  def self.add_caluclated_value (issue, statuses, owner, repo)
      # if IssuesStatus::GITHUB_DB_STORE
      #     isi = IssuesStatusIssue.where(issue_id: issue["id"]).first
      #     status_id =  isi.try(:issues_status_id)|| 1
      #     issue["status"] = IssuesStatus.find_by_id(status_id);
      #     issue["current_status"] = IssuesStatus.find_by_id(status_id).try(:label);
      #     issue["last_update_by"] = UserSerializer.new isi.try(:last_updated_by) || nil
      # else
      issue["status"] = determine_status(issue["labels"], statuses)
      issue["current_status"] = issue["status"].label
      issue["priority"] = determine_priority(issue["labels"])
      # end
      issue["assignee"] = {login: "Unassigned", avatar_url: "/img/unassigned.jpg"} if issue["assignee"].nil?
      issue["milestone"] = {title: "No Milestone"} if issue["milestone"].nil?
      issue["repository"] = repo
      issue["owner"] = owner
      issue
  end

  def self.determine_status(labels, statuses)
      labels ||= []
      label_names = labels.collect{|label| label["name"]}
      statuses.each do |is|
        if label_names.include? is.label
          return is
        end
      end
      IssuesStatus.new({name: 'Backlog', label: '', position: 1})
  end

  def self.determine_priority(labels)
      labels ||= []
      labels = labels.collect{|label| label["name"]}
      value = IssuesPriority::DATA.size  + 1
      IssuesPriority.all.each do |priority|
          if labels.include? priority.github_label
              value = priority.id
              break
          end
      end
      value
  end
end
