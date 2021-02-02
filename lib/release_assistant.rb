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

  DEFAULT_OPTIONS = {
    git: true,
    rubygems: false,
  }.freeze

  class << self
    def define_slop_options(options)
      options.string('-t', '--type', 'Release type (major, minor, or patch)', default: 'patch')
      options.bool('-d', '--debug', 'print debugging info', default: false)
      options.bool('-s', '--show-system-output', 'show system output', default: false)
    end
  end

  def initialize(options)
    @options = options
    logger.debug("Running release with options #{@options}")
  end

  memoize \
  def logger
    Logger.new($stdout).tap do |logger|
      logger.formatter = ->(_severity, _datetime, _progname, msg) { "[release_assistant] #{msg}\n" }
      logger.level = @options[:debug] ? Logger::DEBUG : Logger::INFO
    end
  end

  def run_release
    print_release_plan
    confirm_release_plan
    verify_repository_cleanliness
    remember_initial_branch
    switch_to_master

    update_changelog_for_release
    update_version_file(next_version)
    bundle_install
    commit_changes(message: "Prepare to release v#{next_version}")
    create_tag

    update_changelog_for_alpha
    update_version_file(alpha_version_after_next_version)
    bundle_install
    commit_changes(message: "Bump to v#{alpha_version_after_next_version}")

    push_release
  rescue => error
    logger.error(<<~ERROR_LOG)
      \n
      #{error.class.name.red}: #{error.message.red}
      #{error.backtrace.join("\n")}
    ERROR_LOG
    restore_and_abort(exit_code: 1)
  else
    switch_to_initial_branch
  end

  private

  def print_release_plan
    logger.info("You are running the release process with options #{@options.to_h}!")
    logger.info("Current version is #{current_version}")
    logger.info("Next version will be #{next_version}")
  end

  def confirm_release_plan
    logger.info('Does that look good? [y]n')
    response = $stdin.gets.chomp

    if response.downcase == 'n' # rubocop:disable Performance/Casecmp
      logger.info('Okay, aborting.')
      restore_and_abort(exit_code: 0)
    end
  end

  def verify_repository_cleanliness
    fail 'There are unstaged changes!' if !system('git diff --exit-code')
    fail 'There are staged changes!' if !system('git diff-index --quiet --cached HEAD')
  end

  def remember_initial_branch
    @initial_branch = current_branch
  end

  def current_branch
    system_output('git branch --show-current')
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
          "\\1 v#{next_version} (#{Date.current.iso8601})",
        )
    write_file(changelog_path, new_changelog_content)
  end

  def update_changelog_for_alpha
    old_changelog_content = file_contents(changelog_path)
    write_file(changelog_path, <<~NEW_CHANGELOG_CONTENT)
      ## Unreleased
      [no unreleased changes yet]

      #{old_changelog_content.rstrip}
    NEW_CHANGELOG_CONTENT
  end

  def update_version_file(new_version)
    old_version_file_content = file_contents(version_file_path)
    new_version_file_content =
      old_version_file_content.
        gsub(
          /(VERSION += +['"]).*(['"])/,
          "\\1#{new_version}\\2",
        )
    write_file(version_file_path, new_version_file_content)
  end

  def bundle_install
    execute_command('bundle install')
  end

  def commit_changes(message:)
    execute_command("git add CHANGELOG.md Gemfile.lock #{version_file_path}")
    execute_command("git commit -m '#{message}'")
  end

  def create_tag
    execute_command(%(git tag -m "Version #{next_version}" v#{next_version}))
  end

  def push_release
    if @options[:rubygems] && @options[:git]
      logger.debug('Pushing to RubyGems and git')
      push_to_rubygems_and_git
    elsif @options[:git]
      logger.debug('Pushing to git remote')
      push_to_git
    else
      fail("The combination of options #{@options} is not supported!")
    end
  end

  def push_to_git
    execute_command('git push')
    execute_command('git push --tags')
  end

  def push_to_rubygems_and_git
    execute_command('bundle exec rake release')
  end

  def switch_to_initial_branch
    execute_command("git checkout #{@initial_branch}") if @initial_branch
  end

  def system_output(command)
    `#{command}`.rstrip
  end

  def execute_command(command, raise_error: true)
    logger.debug("Running system command `#{command}`")
    if @options[:show_system_output]
      system(command, exception: raise_error)
    else
      system(command, exception: raise_error, out: File::NULL, err: File::NULL)
    end
  end

  def restore_and_abort(exit_code:)
    if current_branch == 'master'
      execute_command('git reset --hard origin/master')
    end

    if execute_command("git rev-parse v#{next_version}", raise_error: false)
      execute_command("git tag -d v#{next_version}")
    end

    if !execute_command('git diff --exit-code', raise_error: false)
      execute_command("git checkout Gemfile.lock #{changelog_path} #{version_file_path}")
    end

    switch_to_initial_branch
    exit(exit_code)
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

  def alpha_version_after_next_version
    next_patch_version =
      ReleaseAssistant::VersionCalculator.new(current_version: next_version).increment_for('patch')
    "#{next_patch_version}.alpha"
  end

  memoize \
  def version_calculator
    ReleaseAssistant::VersionCalculator.new(current_version: current_version)
  end
end
