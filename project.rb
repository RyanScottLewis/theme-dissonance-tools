require 'pathname'
require 'open3'

module Project
  class << self

    attr_reader :path

    def path=(value)
      @path = value.is_a?(Pathname) ? value : Pathname.new(value.to_s)
    end

    # Set the path from the rakefile
    def setup(value)
      @path = Pathname.new(value.to_s).dirname
    end

    def version
      return @version unless @version.nil?

      @version = @path.join('VERSION').read.strip
    end

    def log(message, &block)
      block_given? ? log_block(message, &block) : puts(message)
    end

    def git_tag
      return @git_tag unless @git_tag.nil?

      # Use capture3 to capture stderr
      output, error, status = Open3.capture3('git describe --tags')
      output = output.strip

      @git_tag = output unless output.empty?

      @git_tag
    end

    protected

    def log_block(message)
      print("#{message}... ")

      begin
        yield

        puts 'OK'
      rescue StandardError => error
        puts 'FAIL'
        puts

        raise(error)
      end
    end

  end
end
