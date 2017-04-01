class Issue

    def self.fetch_single_issue(owner, repository, number, github)
        statuses = Repository.where({owner: owner, name: repository}).first.issues_statuses.order("position desc")
        issue = github.issues.find owner, repository, number, media: 'json'
        issue = issue.to_hash # TODO: pretty fucking iritated by Hashie Mash here.
        issue['owner'] = owner
        issue['repository'] = repository
        issue = Issue.transform(issue)
    end

    def self.fetch_by_owner_and_repo(owner, repository, github)
        #statuses = Repository.where({owner: owner, name: repo}).first.issues_statuses.order("position desc")
        issues = github.issues.list user: owner, repo: repository, auto_pagination: true
        issues.map do |issue|
          issue.owner = owner
          issue.repository = repository
          issue = Issue.transform(issue)
        end
    end

    def self.publish_update_notice(issue, channel, event)
        owner = issue['owner']
        repo = issue['repository']
        sprint_id = issue['sprint']['id'] if issue['sprint']

        Pusher.trigger("private-repo_#{owner}_#{repo}", event, issue) if !Rails.env.test?
        Pusher.trigger("private-sprint_#{sprint_id}", event, issue) if sprint_id.present? && !Rails.env.test?
    end

    def self.transform(issue)
      issue = issue.to_hash
      statuses = []
      si = SprintIssue.where(owner: issue['owner'], repository: issue['repository'], issue_number: issue['number']).first
      if si.nil?
        statuses = Repository.where({owner: issue['owner'], name: issue['repository']}).first.issues_statuses.order("position desc")
      else
        statuses = si.sprint.issues_statuses
        issue['priority_position'] = si.priority_position
        issue["sprint_issue_id"] = si.id
        issue["sprint"] = si.sprint
        issue["points"] = si.points
      end
      issue["status"] = determine_status(issue["labels"], statuses)
      issue["current_status"] = issue["status"].label
      issue["priority"] = determine_priority(issue["labels"])
      # end
      issue["assignee"] = {login: "Unassigned", avatar_url: "/img/unassigned.jpg"} if issue["assignee"].nil?
      issue["milestone"] = {title: "No Milestone"} if issue["milestone"].nil?
      # issue["repository"] = repo
      # issue["owner"] = owner
      return issue
    end

    private
    # def self.add_caluclated_value (issue, statuses, owner, repo)
    #     si = SprintIssue.where(owner: owner, repository: repo, issue_number: issue['number']).first
    #     unless si.nil?
    #       issue['priority_position'] = si.priority_position
    #       issue["sprint_issue_id"] = si.id
    #       issue["sprint"] = si.sprint
    #     end
    #     issue["status"] = determine_status(issue["labels"], statuses)
    #     issue["current_status"] = issue["status"].label
    #     issue["priority"] = determine_priority(issue["labels"])
    #     # end
    #     issue["assignee"] = {login: "Unassigned", avatar_url: "/img/unassigned.jpg"} if issue["assignee"].nil?
    #     issue["milestone"] = {title: "No Milestone"} if issue["milestone"].nil?
    #     issue["repository"] = repo
    #     issue["owner"] = owner
    #     issue
    # end

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
