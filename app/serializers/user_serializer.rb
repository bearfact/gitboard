class UserSerializer < ActiveModel::Serializer
    attributes :id, :uid, :login, :name, :avatar_url, :issues_board_settings
end
