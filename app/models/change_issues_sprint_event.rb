class ChangeIssuesSprintEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :user, :issue, :sprint_id

    validates_presence_of :user, :issue, :sprint_id

    def initialize(attrs={})
        self.user = attrs[:user]
        self.issue = attrs[:issue]
        self.sprint_id = attrs[:sprint_id]
    end

    def save

        if self.sprint_id == 0
          sprint_issue = SprintIssue.accessible_by_user(self.user).find(self.issue['sprint_issue_id'])
          sprint_issue.destroy!
        elsif self.issue['sprint_issue_id']
          sprint_issue = SprintIssue.accessible_by_user(self.user).find(self.issue['sprint_issue_id'])
          sprint_issue.sprint_id = self.sprint_id
          sprint_issue.save!
        else
          SprintIssue.create!(owner: self.issue['owner'], repository: self.issue['repository'], issue_number: self.issue['number'], sprint_id: self.sprint_id)
        end
        res = Issue.fetch_single_issue self.issue['owner'], self.issue['repository'], self.issue['number'], self.user.git_client
        updated_issue = Issue.transform(res)
        Issue.publish_update_notice(updated_issue, "issues", "updated")
        updated_issue
    end
    alias :save! :save

end
