class GithubOwnersController < ApplicationController

    def index
        github = current_user.git_client
        owners = github.orgs.list
        owners = owners.collect(&:login)
        owners << current_user.login
        repos = github.repos.list
        logins = repos.collect{|r| r.owner.login}.uniq

        render json: (logins + owners).uniq, status: 200
    end
end
