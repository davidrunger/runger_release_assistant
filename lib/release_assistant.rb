# frozen_string_literal: true

require 'active_support/all'
require 'colorize'
require 'memoist'
require 'slop'
require 'yaml'

# This `ReleaseAssistant` class is the namespace within which most of the gem's code is written.
# We need to define the class before requiring the modules.
# rubocop:disable Lint/EmptyClass
class ReleaseAssistant
end
# rubocop:enable Lint/EmptyClass

Dir["#{File.dirname(__FILE__)}/release_assistant/**/*.rb"].sort.each { |file| require file }

class ReleaseAssistant
  extend Memoist

  class << self
    def define_slop_options(options)
      options.string('-t', '--type', 'Release type (major, minor, or patch)', default: 'patch')
      options.bool('--debug', 'print debugging info', default: false)
    end

    def logger
      Logger.new($stdout).tap do |logger|
        logger.formatter = ->(_severity, _datetime, _progname, msg) { "#{msg}\n" }
        # default the log level to INFO, but this can be set to `DEBUG` via the `--debug` CLI option
        logger.level = Logger::INFO
      end
    end
  end

  def initialize(options)
    @options = options
  end

  def run_release
    print_release_plan
    confirm_release_plan
    verify_repository_cleanliness
    remember_initial_branch
    switch_to_master
    update_changelog_for_release
    update_version_file
    bundle_install
    commit_changes
    execute_source_control_push
    switch_to_original_branch
  end

  private

  def print_release_plan
    logger.info("You are running the release process with options #{@options.to_h}!")
    logger.info("Current version is #{current_version}")
    logger.info("Next version will be #{next_version}")
  end

  def confirm_release_plan
    puts('Does that sound good? [y]n')
    response = gets.chomp

    if response.downcase == 'n' # rubocop:disable Performance/Casecmp
      puts('Okay, aborting.')
      exit(1)
    end
  end

  def verify_repository_cleanliness
    fail 'There are unstaged changes!' if !system('git diff --exit-code')
    fail 'There are staged changes!' if !system('git diff-index --quiet --cached HEAD')
  end

  def remember_initial_branch
    @initial_branch = system_output('git branch --show-current')
  end

  def switch_to_master
    execute_command('git checkout master')
  end

  def update_changelog_for_release
    old_changelog_content = file_contents(changelog_path)
    new_changelog_content =
      old_changelog_content.
        gsub(
          /(#+) Unreleased/,
          "\1 v#{next_version} (#{Date.current.iso8601})",
        )
    write_file(changelog_path, new_changelog_content)
  end

  def update_version_file
    old_version_file_content = file_contents(version_file_path)
    new_version_file_content =
      old_version_file_content.
        gsub(
          /(VERSION += +['"])(.*)(['"])/,
          "\1#{next_version}\2",
        )
    write_file(version_file_path, new_version_file_content)
  end

  def bundle_install
    execute_command('bundle install')
  end

  def commit_changes
    execute_command("git add CHANGELOG.md Gemfile.lock #{version_file_path}")
    execute_command("git commit -m 'Prepare to release v#{next_version}'")
  end

  def execute_source_control_push
    execute_command(%(git tag -m "Version #{next_version}" v#{next_version}))
    execute_command('git push')
  end

  def switch_to_original_branch
    execute_command("git checkout #{@initial_branch}")
  end

  def system_output(command)
    logger.debug("Getting output from `#{command}`")
    `#{command}`.rstrip
  end

  def execute_command(command)
    logger.debug("Running system command `#{command}`")
    system(command)
  end

  def file_path(file_name)
    system_output("find . -type f -name #{file_name}").delete_prefix('./')
  end

  def file_contents(file_path)
    File.read("#{ENV['PWD']}/#{file_path}")
  end

  def write_file(file_path, file_contents)
    File.write("#{ENV['PWD']}/#{file_path}", file_contents)
  end

  memoize \
  def version_file_path
    file_path('version.rb')
  end

  memoize \
  def changelog_path
    file_path('CHANGELOG.md')
  end

  memoize \
  def current_version
    file_contents(version_file_path).
      match(/VERSION += +['"](?<version>.*)['"]/)&.
      named_captures&.to_h&.
      dig('version')
  end

  memoize \
  def next_version
    version_calculator.increment_for(@options[:type])
  end

  memoize \
  def version_calculator
    ReleaseAssistant::VersionCalculator.new(current_version: current_version)
  end

  def logger
    ReleaseAssistant.logger
  end
end
