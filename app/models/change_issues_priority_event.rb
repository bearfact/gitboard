class ChangeIssuesPriorityEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue_id, :priority, :old_priority, :user, :issue_number, :owner, :repo

    validates_presence_of :issue_id, :priority, :old_priority, :user, :issue_number, :owner, :repo

    def initialize(attrs={})
        self.issue_id = attrs[:issue_id]
        self.priority = attrs[:priority]
        self.user = attrs[:user]
        self.old_priority= attrs[:old_priority]
        self.issue_number = attrs[:issue_number]
        self.owner = attrs[:owner]
        self.repo = attrs[:repo]
    end

    def save
        #save by updating github label
        new_github_priority_label = IssuesPriority.find_by_id(self.priority).try(:github_label);
        old_github_priority_label = IssuesPriority.find_by_id(self.old_priority).try(:github_label);
        github = user.git_client

        if !new_github_priority_label.nil?
            github.issues.labels.add self.owner, self.repo, self.issue_number, new_github_priority_label
        end

        if !old_github_priority_label.nil?
            github.issues.labels.remove self.owner, self.repo, self.issue_number, label_name: old_github_priority_label
        end
        res = Issue.fetch_single_issue self.owner, self.repo, self.issue_number, github
        Issue.publish_update_notice(res, self.owner, self.repo, "issues", "updated")
        res
    end
    alias :save! :save

end
