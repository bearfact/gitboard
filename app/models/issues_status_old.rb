class IssuesStatusOld

  GITHUB_DB_STORE = false

  DATA = {
      1 => {
          :id    => 1,
          :name  => "Pending",
          :label => 'pending',
      },
      2 => {
          :id    => 2,
          :name  => "In Progress",
          :label => 'in_progress',
          :github_label => 'status:working'
      },
      3 => {
          :id    => 3,
          :name  => "Fixed",
          :label => 'fixed',
          :github_label => 'status:fixed'
      },
      4 => {
          :id    => 4,
          :name  => "Ready For QA",
          :label => 'ready_for_qa',
          :github_label => 'status:qa'
      },
      5 => {
          :id    => 5,
          :name  => "Complete",
          :label => 'complete',
          :github_label => 'status:passed_qa'
      }
  }

  def self.find(id)
    self.find_by_id(id) || raise(NotFound.new(id))
  end

  def self.find_by_id(id)
    attrs = DATA[id.to_i]
    self.new(attrs) if attrs
  end

  def self.find_by_label(label)
    self.find_by_id(self.id_for(label))
  end

  def self.all
    DATA.map{|(id, attrs)| self.new(attrs) }.sort
  end

  def self.id_for(label)
    DATA.values.inject(nil) do |match, attrs|
      attrs[:label] == label.to_s ? attrs[:id] : match
    end
  end

  attr_reader :id, :name, :label, :github_label

  def initialize(attrs = nil)
    attrs ||= {}
    @id   = attrs[:id]
    @name = attrs[:name]
    @label  = attrs[:label]
    @github_label = attrs[:github_label]
  end

  # defines: active?, deactivated?
  DATA.each do |id, attrs|
    define_method("#{attrs[:label]}?"){ self.id == id }
  end

  def <=>(other)
    if other.kind_of?(IssuesStatus)
      self.id <=> other.id
    else
      super
    end
  end

  class NotFound < RuntimeError
    def initialize(key)
      super "An user status with id #{key.inspect} doesn't exist"
    end
  end

end
