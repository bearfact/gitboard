class Issue

    def self.fetch_single_issue(owner, repo, number, github)
        statuses = Repository.where({owner: owner, name: repo}).first.issues_statuses.order("position desc")
        issue = github.issues.find owner, repo, number, media: 'json'
        issue = add_caluclated_value issue.to_hash, statuses
    end

    def self.fetch_by_owner_and_repo(owner, repo, github)
        statuses = Repository.where({owner: owner, name: repo}).first.issues_statuses.order("position desc")
        issues = github.issues.list user: owner, repo: repo, auto_pagination: true
        issues.each do |issue|
            issue = add_caluclated_value(issue, statuses)
        end
    end

    private
    def self.add_caluclated_value (issue, statuses)
        if IssuesStatus::GITHUB_DB_STORE
            isi = IssuesStatusIssue.where(issue_id: issue["id"]).first
            status_id =  isi.try(:issues_status_id)|| 1
            issue["status"] = IssuesStatus.find_by_id(status_id);
            issue["current_status"] = IssuesStatus.find_by_id(status_id).try(:label);
            issue["last_update_by"] = UserSerializer.new isi.try(:last_updated_by) || nil
        else
            issue["status"] = determine_status(issue["labels"], statuses)
            issue["current_status"] = issue["status"].label
            issue["priority"] = determine_priority(issue["labels"])
        end
        issue["assignee"] = {login: "Unassigned", avatar_url: "/img/unassigned.jpg"} if issue["assignee"].nil?
        issue["milestone"] = {title: "No Milestone"} if issue["milestone"].nil?
        issue
    end

    def self.determine_status(labels, statuses)
        label_names = labels.collect{|label| label["name"]}
        statuses.each do |is|
          if label_names.include? is.label
            return is
          end
        end
        IssuesStatus.new({name: 'Backlog', label: '', position: 1})
    end

    def self.determine_priority(labels)
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
