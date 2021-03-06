require 'pathname'
require 'rake'
require 'rake/tasklib'

require_relative '../../project'

module Tasks
  module Build
    class Header < Rake::TaskLib
      def self.define(&block)
        new(&block).define
      end

      # Patterns for scanning file header comments
      PATTERNS = {
        # Each line starts with '<!-- ##' or whitespace
        #
        # xml, html, svg
        xml: /^\s*(<!--\s+##.*\s+..>)?$/,

        # Each line starts with '##' or whitespace
        #
        # ruby, python, shell
        hash: /^\s*(##.*)?$/,
      }

      # The list of file extensions which should use the `:xml` pattern by default
      XML_EXTENSIONS = %w[.xml .html .itermcolors]

      def initialize
        @source_paths = Pathname.glob(Project.path.join(*%w[lib ** *]))
        @template_path = Project.path.join(*%w[templates header.txt])

        yield(self) if block_given?
      end

      # Get the pattern to match when scanning for an old header
      #
      # @return [Regexp]
      attr_reader :pattern

      # Set the pattern to match when scanning for an old header
      #
      # @param [Regexp, Symbol, :to_s] value
      #   When a Symbol is given, it is fetched from #{PATTERNS}.
      #   When a Regexp is given, it is used directly.
      #   When a String is given, it is converted into a Regexp.
      # @return [Regexp]
      def pattern=(value)
        value = PATTERNS[value] if value.is_a?(Symbol)
        value = Regexp.new(value.to_s) unless value.is_a?(Regexp)

        @pattern = value
      end

      # Get the paths to prepend the header to
      #
      # @return [<String>]
      attr_reader :source_paths

      # Set the paths to the source files prepend the header to
      #
      # @param [<#to_s>] value The paths, which can be glob patterns
      # @return [<String>]
      def source_paths=(value)
        @source_paths = value.to_a.
          collect { |glob| Pathname.glob(glob.to_s) }.
          flatten.
          uniq.
          collect(&:expand_path)
      end

      attr_reader :template_path

      def template_path=(value)
        @template_path = value.is_a?(Pathname) ? value : Pathname.new(value.to_s)
      end

      def define
        namespace :build do
          desc 'Prepend the header to source files'
          task :header do
            @source_paths.each do |source_path|
              pattern = @pattern

              if pattern.nil?
                pattern = if XML_EXTENSIONS.include?(source_path.extname)
                  PATTERNS[:xml]
                else
                  PATTERNS[:hash]
                end
              end

              Project.log("Adding header to #{source_path.relative_path_from(Project.path)}") do
                source_data = source_path.read
                source_data = strip_header(source_data, pattern)

                header_data = generate_header(source_path)

                source_data = "#{header_data}\n#{source_data}"

                source_path.open('w+') { |file| file.puts(source_data) }
              end
            end
          end

          task default: :header
        end
      end

      protected

      # Strip an existing header by scanning using #pattern
      def strip_header(source_data, pattern)
        scanning_header_comments = true
        lines = source_data.lines.each_with_object([]) do |line, memo|
          next if scanning_header_comments && line =~ pattern
          scanning_header_comments = false

          memo << line
        end

        lines.join
      end

      def generate_header(source_path)
        template_path = Project.path.join(@template_path)
        header_data = template_path.read
        header_data = header_data % { version: Project.version }

        header_data = if XML_EXTENSIONS.include?(source_path.extname)
          lines = header_data.lines
          longest_line_length = lines.collect(&:length).max
          lines.collect { |line| "<!-- ## #{line.chomp.ljust(longest_line_length)} -->\n" }.join
        else
          header_data.lines.collect { |line| "## #{line.chomp}\n" }.join
        end

        header_data
      end
    end
  end
end
