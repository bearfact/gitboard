class ChangeIssuesMilestoneEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue, :user, :milestone_number

    validates_presence_of :issue, :user, :milestone_number

    def initialize(attrs={})
        self.issue = attrs[:issue]
        self.user = attrs[:user]
        self.milestone_number = attrs[:milestone_number]
    end

    def save
        self.milestone_number = nil if self.milestone_number == 0
        github = user.git_client
        github.issues.edit user: self.issue['owner'], repo: self.issue['repository'], number: self.issue['number'], milestone: self.milestone_number
        res = Issue.fetch_single_issue self.issue['owner'], self.issue['repository'], self.issue['number'], github
        updated_issue = Issue.transform(res)
        Issue.publish_update_notice(updated_issue, "issues", "updated")
        updated_issue
    end
    alias :save! :save

end
