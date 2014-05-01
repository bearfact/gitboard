class IssuesStatusIssue < ActiveRecord::Base
    validates_presence_of :issue_id, :issues_status_id, :last_updated_by_id
    validates_uniqueness_of :issue_id
    belongs_to :user, :foreign_key => :last_updated_by_id


    def status
        @status ||= UsersStatus.find_by_id(self.status_id)
    end

    def last_updated_by
        User.find(self.last_updated_by_id)
    end
end