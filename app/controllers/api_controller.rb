class ApiController < ActionController::Base
  include Authenticable
  #protect_from_forgery with: :null_session
  #respond_to :json
end
