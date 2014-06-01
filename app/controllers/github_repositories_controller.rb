class GithubRepositoriesController < ApiController

    def index
        github = current_user.git_client
        repos = github.repos.list
        org_repos = []
        begin
          org_repos = github.orgs.get params['owner']+"/repos"
        rescue
        end
        repos = repos.reject{|r| r.owner.login != params['owner']}

        all = []
        repos.each do |r|
          all << r
        end
        org_repos.each do |r|
          all << r
        end
        #if params['owner'] == current_user.login
        #    repos = github.repos.list
        #else
        #    repos = github.orgs.get params['owner']+"/repos"
        #end
        render json: all
    end

    def hooks
        github = current_user.git_client
        hooks = github.repos.hooks.list params[:owner], params[:repo]
        render json: hooks
    end
end
