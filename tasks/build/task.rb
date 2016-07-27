require 'rake'
require 'rake/tasklib'

require_relative 'header'
require_relative 'readme'

module Tasks
  module Build
    class Task < Rake::TaskLib
      def self.define(&block)
        new(&block).define
      end

      def initialize
        @header = Header.new
        @readme = Readme.new

        yield(self) if block_given?
      end

      attr_reader :header

      attr_reader :readme

      def define
        @header.define
        @readme.define

        desc 'Build the project'
        task build: 'build:default'
      end
    end
  end
end
