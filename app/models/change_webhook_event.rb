class ChangeWebhookEvent
    include ActiveModel::Serializers::JSON
    include ActiveRecord::Validations
    extend ActiveModel::Naming

    attr_accessor :user, :owner, :repo, :hook_id

    validates_presence_of :user, :owner, :repo

    def initialize(attrs={})
        self.user = attrs[:user]
        self.owner = attrs[:owner]
        self.repo = attrs[:repo]
        self.hook_id = attrs[:hook_id]
    end

    def save
        github = user.git_client

        if !self.hook_id
            res = github.repos.hooks.create self.owner, self.repo, name: "web", active: true, config: {url: 'https://gitboard.io/issueshook', content_type: 'json', secret: '', insecure_ssl: 0}, events: ['issues']
        else
            res = github.repos.hooks.delete self.owner, self.repo, self.hook_id
        end
        res
    end
    alias :save! :save

end
