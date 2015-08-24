class IssuesStatus < ActiveRecord::Base
    belongs_to :repository
    belongs_to :sprint

    validates_presence_of :name, :position
    validates_uniqueness_of :label, :scope => [:repository_id]
    #validates_uniqueness_of :position, :scope => [:repository_id]

    default_scope { order('position') }

    # GITHUB_DB_STORE = false

end
