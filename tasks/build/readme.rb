require 'pathname'
require 'rake'
require 'rake/tasklib'

require_relative '../../project'

module Tasks
  module Build
    class Readme < Rake::TaskLib
      def self.define(&block)
        new(&block).define
      end

      def initialize
        @template_path = Project.path.join(*%w[templates README.txt])

        yield(self) if block_given?
      end

      attr_reader :template_path

      def template_path=(value)
        @template_path = value.is_a?(Pathname) ? value : Pathname.new(value.to_s)
      end

      def define
        namespace :build do
          desc 'Build the readme'
          task :readme do
            template_data = @template_path.read

            readme_data = template_data % { version: Project.version }
            readme_path = Project.path.join('README.md')

            Project.job("Generating #{readme_path.relative_path_from(Project.path)}") do
              readme_path.open('w+') { |file| file.puts(readme_data) }
            end
          end

          task default: :readme
        end
      end
    end
  end
end
