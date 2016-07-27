require 'pathname'
require 'open3'

def log_message(message)
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

PROJECT_PATH = Pathname.new(__FILE__).join(*%w[.. ..]).expand_path
PROJECT_VERSION = PROJECT_PATH.join('VERSION').read.strip

def current_git_tag
  return @current_git_tag unless @current_git_tag.nil?

  output, error, status = Open3.capture3('git describe --tags') # Use capture3 to capture stderr
  output = output.strip

  @current_git_tag = output unless output.empty?

  @current_git_tag
end

def check_git_tag_version
  raise 'Git tag and project version are the same' if PROJECT_VERSION == current_git_tag
end

namespace :build do

  task :readme do
    template_path = PROJECT_PATH.join(*%w[templates Readme.txt])
    template_data = template_path.read

    readme_data = template_data % { version: PROJECT_VERSION }
    readme_path = PROJECT_PATH.join('Readme.md')

    log_message "Generating #{readme_path.relative_path_from(PROJECT_PATH)}" do
      readme_path.open('w+') { |file| file.puts(readme_data) }
    end
  end

  task :header do
    source_path = PROJECT_PATH.join(*%w[lib Dissonance.itermcolors])
    source_data = source_path.read

    # Strip current header
    scanning_header_comments = true
    source_data = source_data.lines.each_with_object([]) do |line, memo|
      next if scanning_header_comments && line =~ /^\s*((<!)?-->?.*)?$/
      scanning_header_comments = false

      memo << line
    end.join

    header_path = PROJECT_PATH.join(*%w[templates header.txt])
    header_data = header_path.read
    header_data = header_data % { version: PROJECT_VERSION }

    source_data = "#{header_data}\n#{source_data}"

    log_message "Adding header to #{source_path.relative_path_from(PROJECT_PATH)}" do
      source_path.open('w+') { |file| file.puts(source_data) }
    end
  end

  task default: [:readme, :header]
end

desc 'Build the project'
task build: 'build:default'

namespace :release do
  task :commit do
    log_message 'Comitting to Git' do
      check_git_tag_version

      sh "git commit -am '#{PROJECT_VERSION}'"
    end
  end

  task :tag do
    log_message "Adding Git tag #{PROJECT_VERSION}" do
      check_git_tag_version

      sh "git tag #{PROJECT_VERSION}"
    end
  end

  task :push do
    log_message 'Pushing to Git' do
      check_git_tag_version

      sh 'git push origin master --tags'
    end
  end

  task default: [:build, :commit, :tag, :push]
end

desc 'Release the project'
task release: 'release:default'
