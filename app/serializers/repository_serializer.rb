class RepositorySerializer < ActiveModel::Serializer
    attributes :id, :owner, :name, :url, :description, :column_count#, :can_edit
    has_many :issues_statuses

    def column_count
      self.issues_statuses.count
    end

    #def can_edit
    #    current_user.id == object.user_id
    #end
end
