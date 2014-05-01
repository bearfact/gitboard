class ApplicationController < ActionController::Base
    include Authenticable
    protect_from_forgery with: :null_session
end
