require_relative 'tasks/task'

module Tasks
  def self.define(&block)
    Task.define(&block)
  end
end
