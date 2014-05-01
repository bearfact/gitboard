class ChangeIssuesStatusEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue, :old_status_label, :user

    validates_presence_of :issue, :old_status_label, :user

    def initialize(attrs={})
        self.issue = attrs[:issue]
        self.user = attrs[:user]
        self.old_status_label = attrs[:old_status_label]

    end

    def save
        new_github_status_label = IssuesStatus.find_by_label(self.issue['status']['label']).try(:label);
        old_github_status_label = IssuesStatus.find_by_label(self.old_status_label).try(:label);
        github = user.git_client

        if !new_github_status_label.blank?
            github.issues.labels.add self.issue['owner'], self.issue['repository'], self.issue['number'], new_github_status_label
        end
        if !old_github_status_label.blank?
            github.issues.labels.remove self.issue['owner'], self.issue['repository'], self.issue['number'], label_name: URI.encode(old_github_status_label)
        end
        res = Issue.fetch_single_issue self.issue['owner'], self.issue['repository'], self.issue['number'], github
        updated_issue = Issue.transform(res)
        Issue.publish_update_notice(updated_issue, "issues", "updated")
        updated_issue
    end
    alias :save! :save

end
