class IssuesPrioritiesController < ApplicationController

    def index
        priorities = IssuesPriority.all
        render json: priorities, status: 200
    end
end