class IssuesPrioritiesController < ApiController

    def index
        priorities = IssuesPriority.all
        render json: priorities
    end
end
