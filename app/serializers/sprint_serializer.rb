class SprintSerializer < ActiveModel::Serializer
    attributes :id, :owner, :name, :due_date, :column_count, :status
    has_many :issues_statuses

    def column_count
      self.issues_statuses.count
    end
end
