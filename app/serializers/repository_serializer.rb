class RepositorySerializer < ActiveModel::Serializer
    attributes :id, :owner, :name, :url, :description, :column_count
    has_many :issues_statuses

    def column_count
      self.issues_statuses.count
    end
end
