require_relative 'build/task'

module Tasks
  module Build
    def self.define(&block)
      Task.define(&block)
    end
  end
end
