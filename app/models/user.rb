class User < ActiveRecord::Base
    store_accessor :issues_board_settings
    has_many :repository_users
    has_many :repositories, :through => :repository_users

    validates_presence_of :provider, :uid, :login, :oauth_token
    validates_uniqueness_of :login, :scope => :provider

    def self.from_omniauth(auth)
        thing = auth.slice(:provider, :uid)
        where(provider: thing.provider, uid: thing.uid).first_or_initialize.tap do |user|
            user.provider = auth.provider
            user.uid = auth.uid
            user.email = auth.info.email
            user.login = auth.extra.raw_info.login
            user.name = auth.extra.raw_info.name
            user.avatar_url = auth.extra.raw_info.avatar_url
            user.oauth_token = auth.credentials.token
            user.save!
        end
    end

    def git_client
        github = Github.new :oauth_token => self.oauth_token
    end
end
