class ChangeIssuesPriorityEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue, :priority, :user

    validates_presence_of :issue, :priority, :user

    def initialize(attrs={})
        self.issue = attrs[:issue]
        self.priority = attrs[:priority]
        self.user = attrs[:user]
    end

    def save
        #save by updating github label
        new_github_priority_label = IssuesPriority.find_by_id(self.priority).try(:github_label);
        old_github_priority_label = IssuesPriority.find_by_id(self.issue['priority']).try(:github_label);
        github = user.git_client

        if !new_github_priority_label.nil? && self.priority != 4
            github.issues.labels.add self.issue['owner'], self.issue['repository'], self.issue['number'], new_github_priority_label
        end

        if !old_github_priority_label.nil?
            github.issues.labels.remove self.issue['owner'], self.issue['repository'], self.issue['number'], label_name: old_github_priority_label
        end
        res = Issue.fetch_single_issue self.issue['owner'], self.issue['repository'], self.issue['number'], github
        updated_issue = Issue.transform(res)
        Issue.publish_update_notice(updated_issue, "issues", "updated")
        updated_issue
    end
    alias :save! :save

end
