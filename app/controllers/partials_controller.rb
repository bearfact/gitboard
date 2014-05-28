class PartialsController < ActionController::Metal
    include ActionController::Rendering
    append_view_path "#{Rails.root}/app/views"
    def index
        render partial: "partials/#{params[:path]}"
      end
end
