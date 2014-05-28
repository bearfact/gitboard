class ApiController < ActionController::Metal
    include ActionController::Rendering
    include ActionController::Renderers::All
    include ActionController::MimeResponds
    include AbstractController::Callbacks
    include AbstractController::Helpers
    include ActionController::StrongParameters
    include ActionController::RequestForgeryProtection
    include Authenticable
    protect_from_forgery with: :null_session
    respond_to :json
end
