require 'pathname'
require 'rake'
require 'rake/tasklib'

require_relative '../project'

module Tasks
  class Release < Rake::TaskLib
    def self.define(&block)
      new(&block).define
    end

    def initialize
      yield(self) if block_given?
    end

    def define
      namespace :release do
        task :commit do
          log_message 'Comitting to Git' do
            sh "git commit -am '#{Project.version}'"
          end
        end

        task :tag do
          log_message "Adding Git tag #{Project.version}" do
            sh "git tag #{Project.version}"
          end
        end

        task :push do
          log_message "Pushing Git tag #{Project.version}" do
            sh "git push origin #{Project.version}"
          end
        end

        task default: [:build, :commit, :tag, :push]
      end

      desc 'Release the project'
      task release: 'release:default'
    end

  end
end
