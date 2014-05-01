class PartialsController < ApplicationController

    def index
        render "partials/#{params[:path]}"
      end
end
