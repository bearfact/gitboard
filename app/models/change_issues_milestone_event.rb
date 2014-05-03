class ChangeIssuesMilestoneEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue_number, :owner, :repo, :user, :milestone_number

    validates_presence_of :issue_number, :owner, :repo, :user, :milestone_number

    def initialize(attrs={})
        self.issue_number = attrs[:issue_number]
        self.repo = attrs[:repo]
        self.owner = attrs[:owner]
        self.user = attrs[:user]
        self.milestone_number = attrs[:milestone_number]
    end

    def save
        self.milestone_number = nil if self.milestone_number == 0
        github = user.git_client
        github.issues.edit user: self.owner, repo: self.repo, number: self.issue_number, milestone: self.milestone_number
        res = Issue.fetch_single_issue self.owner, self.repo, self.issue_number, github
        Issue.publish_update_notice(res, self.owner, self.repo, "issues", "updated")
        res
    end
    alias :save! :save

end
