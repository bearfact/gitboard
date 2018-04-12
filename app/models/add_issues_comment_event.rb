class AddIssuesCommentEvent
  include ActiveModel::Serializers::JSON
  include ActiveRecord::Validations
  extend ActiveModel::Naming

  attr_accessor :issue, :user, :comment, :close

  validates_presence_of :issue, :user, :comment, :close

  def initialize(attrs = {})
    self.issue = attrs[:issue]
    self.user = attrs[:user]
    self.comment = attrs[:comment]
    self.close = attrs[:close]
  end

  def save
    github = user.git_client
    unless self.comment.blank?
      github.issues.comments.create self.issue["owner"], self.issue["repository"], self.issue["number"], {body: self.comment}
    end
    if self.close
      github.issues.edit user: self.issue["owner"], repo: self.issue["repository"], number: self.issue["number"], state: "closed"
    end
    res = Issue.fetch_single_issue self.issue["owner"], self.issue["repository"], self.issue["number"], github
    res
  end

  alias :save! :save
end
