class AddIssuesCommentEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue_number, :owner, :repo, :user, :comment, :close

    validates_presence_of :issue_number, :owner, :repo, :user, :comment, :close

    def initialize(attrs={})
        self.issue_number = attrs[:issue_number]
        self.repo = attrs[:repo]
        self.owner = attrs[:owner]
        self.user = attrs[:user]
        self.comment = attrs[:comment]
        self.close = attrs[:close]
    end

    def save
        github = user.git_client
        unless self.comment.blank?
            github.issues.comments.create self.owner, self.repo, self.issue_number, {body: self.comment}
        end
        if self.close
            github.issues.edit user: self.owner, repo: self.repo, number: self.issue_number, state: "closed"
        end
        res = Issue.fetch_single_issue self.owner, self.repo, self.issue_number, github
        #Issue.publish_update_notice(res, self.owner, self.repo, "issues", "updated")
        res
    end
    alias :save! :save

end