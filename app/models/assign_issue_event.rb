class AssignIssueEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue_number, :owner, :repo, :user, :user_login

    validates_presence_of :issue_number, :owner, :repo, :user, :user_login

    def initialize(attrs={})
        self.issue_number = attrs[:issue_number]
        self.repo = attrs[:repo]
        self.owner = attrs[:owner]
        self.user = attrs[:user]
        self.user_login = attrs[:user_login]
    end

    def save
        self.user_login = '' if self.user_login == "Unassigned"
        github = user.git_client
        github.issues.edit user: self.owner, repo: self.repo, number: self.issue_number, assignee: self.user_login
        res = Issue.fetch_single_issue self.owner, self.repo, self.issue_number, github
        Issue.publish_update_notice(res, self.owner, self.repo, "issues", "updated")
        res
    end
    alias :save! :save

end
