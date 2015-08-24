class ChangeIssuesStatusEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :issue_id, :status_label, :old_status_label, :user, :issue_number, :owner, :repo

    validates_presence_of :issue_id, :status_label, :old_status_label, :user, :issue_number, :owner, :repo

    def initialize(attrs={})
        self.issue_id = attrs[:issue_id]
        self.status_label = attrs[:status_label]
        self.user = attrs[:user]
        self.old_status_label = attrs[:old_status_label]
        self.issue_number = attrs[:issue_number]
        self.owner = attrs[:owner]
        self.repo = attrs[:repo]
    end

    def save
#save in the apps database
        # if IssuesStatus::GITHUB_DB_STORE
        #     status = IssuesStatus.find_by_label(self.status_label)
        #     isi = IssuesStatusIssue.where(issue_id: self.issue_id).first
        #     if isi.nil?
        #         isi = IssuesStatusIssue.create issue_id: self.issue_id, issues_status_id: status.id, last_updated_by_id: self.user.id
        #     else
        #         isi.update issues_status_id: status.id, last_updated_by_id: self.user.id
        #     end
        # else
        #save by updating github label
        new_github_status_label = IssuesStatus.find_by_label(self.status_label).try(:label);
        old_github_status_label = IssuesStatus.find_by_label(self.old_status_label).try(:label);
        github = user.git_client

        if !new_github_status_label.blank?
            github.issues.labels.add self.owner, self.repo, self.issue_number, new_github_status_label
        end
        if !old_github_status_label.blank?
            github.issues.labels.remove self.owner, self.repo, self.issue_number, label_name: URI.encode(old_github_status_label)
        end
        res = Issue.fetch_single_issue self.owner, self.repo, self.issue_number, github
        Issue.publish_update_notice(res, self.owner, self.repo, "issues", "updated")
        res
        #end
    end
    alias :save! :save

end
