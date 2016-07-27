require 'rake'
require 'rake/tasklib'

require_relative 'build/task'
require_relative 'release'

module Tasks
  class Task < Rake::TaskLib
    def self.define(&block)
      new(&block).define
    end

    def initialize
      @build = Build.new
      @release = Release.new

      yield(self) if block_given?
    end

    attr_reader :build

    attr_reader :release

    def define
      @build.define
      @release.define
    end
  end
end
