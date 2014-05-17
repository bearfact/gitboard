class PartialsController < ApplicationController

    def index
        render partial: "partials/#{params[:path]}"
      end
end
