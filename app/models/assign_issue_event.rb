class AssignIssueEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue, :user, :user_login

    validates_presence_of :issue, :user, :user_login

    def initialize(attrs={})
        self.issue = attrs[:issue]
        self.user = attrs[:user]
        self.user_login = attrs[:user_login]
    end

    def save
        self.user_login = '' if self.user_login == "Unassigned"
        github = user.git_client
        github.issues.edit user: self.issue['owner'], repo: self.issue['repository'], number: self.issue['number'], assignee: self.user_login
        res = Issue.fetch_single_issue self.issue['owner'], self.issue['repository'], self.issue['number'], github
        updated_issue = Issue.transform(res)
        Issue.publish_update_notice(updated_issue, "issues", "updated")
        updated_issue
    end
    alias :save! :save

end
