class GithubOwnersController < ApiController

    def index
        github = current_user.git_client
        owners = github.orgs.list auto_pagination: true
        owners = owners.collect(&:login)
        owners << current_user.login
        repos = github.repos.list auto_pagination: true
        logins = repos.collect{|r| r.owner.login}.uniq

        render json: (logins + owners).uniq
    end
end
