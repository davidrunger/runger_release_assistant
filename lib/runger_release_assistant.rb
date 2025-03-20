# frozen_string_literal: true

require 'active_support/all'
require 'io/console'
require 'memo_wise'
require 'rainbow/refinement'
require 'slop'
require 'yaml'

module StringWithPipe
  refine String do
    def pipe(command)
      IO.popen(command, 'r+') do |io|
        io.puts(self)
        io.close_write
        io.read
      end
    end
  end
end

using Rainbow
using StringWithPipe

# We need to define the class before requiring the modules.
# rubocop:disable Lint/EmptyClass
class RungerReleaseAssistant
end
# rubocop:enable Lint/EmptyClass

Dir["#{File.dirname(__FILE__)}/runger_release_assistant/**/*.rb"].each { |file| require file }

class RungerReleaseAssistant
  prepend MemoWise

  class UnknownPrimaryBranch < StandardError
    DEFAULT_MESSAGE = <<~MESSAGE.squish
      Failed to automatically determine primary branch. Specify it via the `primary_branch` option.
    MESSAGE

    def initialize(message = DEFAULT_MESSAGE)
      super
    end
  end

  DEFAULT_OPTIONS = { rubygems: false }.freeze

  class << self
    def define_slop_options(options)
      options.string('-t', '--type', 'Release type (major, minor, or patch)', default: 'patch')
      options.bool('-d', '--debug', 'print debugging info', default: false)
      options.bool('-s', '--show-system-output', 'show system output', default: false)
    end
  end

  def initialize(cli_options = {}) # rubocop:disable Style/OptionHash
    config_file_options = RungerReleaseAssistant::ConfigFileReader.new.options_hash

    @options =
      DEFAULT_OPTIONS.
        merge(config_file_options).
        merge(cli_options)

    logger.debug("Running release with options #{@options}")
  end

  memo_wise \
  def logger
    Logger.new($stdout).tap do |logger|
      logger.formatter =
        ->(_severity, _datetime, _progname, msg) do
          "[runger_release_assistant] #{msg}\n"
        end
      logger.level = @options[:debug] ? Logger::DEBUG : Logger::INFO
    end
  end

  def run_release
    ensure_on_main_branch
    print_release_info
    confirm_release_looks_good
    verify_repository_cleanliness

    update_changelog_for_release
    update_version_file(next_version)
    bundle_install
    commit_changes(message: "Prepare to release v#{next_version}")
    create_tag
    push_to_rubygems_and_or_git
  rescue => error
    logger.error(<<~ERROR_LOG)
      \n
      #{error.class.name.red}: #{error.message.red}
      #{error.backtrace.join("\n")}
    ERROR_LOG
    restore_and_abort(exit_code: 1)
  else
    run_post_release_command
  end

  def tag_prefix
    @options[:tag_prefix]
  end

  private

  def ensure_on_main_branch
    if current_branch != primary_branch
      fail('You must be on the primary branch to release!')
    end
  end

  def print_release_info
    logger.info("You are running the release process with options #{@options.to_h}.")

    logger.info(<<~INFO.squish)
      Current released version is
      #{(current_released_version || '[none]').blue}
      (tag: #{latest_tag}).
    INFO

    logger.info(<<~INFO.squish)
      Next version will be #{next_version.green}
      (tag: #{next_git_tag}).
    INFO

    print_changelog_content_of_upcoming_release

    print_diff_since_last_release
  end

  def confirm_release_looks_good
    logger.info('Does that look good? [y]n')

    case $stdin.getch
    when 'n', "\u0003"
      logger.info('Okay, aborting.')
      restore_and_abort(exit_code: 0)
    when 'y', "\r"
      # (proceed)
    else
      logger.info("That's not an option.")
      confirm_release_looks_good
    end
  end

  def verify_repository_cleanliness
    fail 'There are unstaged changes!' if !system('git diff --exit-code')
    fail 'There are staged changes!' if !system('git diff-index --quiet --cached HEAD')
  end

  def current_branch
    system_output('git branch --show-current')
  end

  memo_wise \
  def primary_branch
    @options[:primary_branch] ||
      common_primary_branch_name ||
      (raise(UnknownPrimaryBranch))
  end

  memo_wise \
  def common_primary_branch_name
    `git branch`.scan(/ (main|master|trunk)$/).dig(0, 0)
  end

  def update_changelog_for_release
    old_changelog_content = file_contents(changelog_path)
    new_changelog_content =
      old_changelog_content.
        gsub(
          /(#+) Unreleased/,
          "\\1 v#{next_version} (#{Date.current.iso8601})",
        )

    write_file(changelog_path, <<~NEW_CHANGELOG_CONTENT)
      ## Unreleased
      [no unreleased changes yet]

      #{new_changelog_content.rstrip}
    NEW_CHANGELOG_CONTENT
  end

  def update_version_file(new_version)
    old_version_file_content = file_contents(version_file_path)
    new_version_file_content =
      old_version_file_content.gsub(/(VERSION += +['"]).*(['"])/, "\\1#{new_version}\\2")
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
    execute_command(%(git tag -a '#{next_git_tag}' -m 'Version #{next_version}'))
  end

  memo_wise \
  def next_git_tag
    git_tag(next_version)
  end

  def git_tag(version)
    "#{tag_prefix}v#{version}"
  end

  def push_to_rubygems_and_or_git
    if @options[:rubygems]
      push_to_rubygems
    end

    push_to_git
  end

  def push_to_rubygems
    logger.debug('Pushing to RubyGems and git')
    # Always show system output because 2FA should be enabled, which requires user to see the prompt
    execute_command('bundle exec rake release', show_system_output: true)
  end

  def push_to_git
    logger.debug('Pushing to git remote')
    execute_command('git push')
    execute_command('git push --tags')
  end

  def run_post_release_command
    post_release_command_query_command =
      'runger-config --directory ~/code/dotfiles post-release-command'

    if system("#{post_release_command_query_command} --silent")
      post_release_command = `#{post_release_command_query_command}`.rstrip
      execute_command(post_release_command, clear_bundler_context: true)
    end
  end

  def system_output(command)
    `#{command}`.rstrip
  end

  def execute_command(
    command,
    raise_error: true,
    show_system_output: false,
    clear_bundler_context: false
  )
    logger.debug("Running system command `#{command}`")

    env =
      if clear_bundler_context
        ENV.keys.grep(/\A(BUNDLE|RUBY)/).to_h { [_1, nil] }
      else
        {}
      end

    kwargs =
      if @options[:show_system_output] || show_system_output
        {}
      else
        { out: File::NULL, err: File::NULL }
      end

    system(env, command, exception: raise_error, **kwargs)
  end

  def restore_and_abort(exit_code:)
    if current_branch == primary_branch
      execute_command("git reset --hard origin/#{primary_branch}")
    end

    if execute_command("git rev-parse #{next_git_tag}", raise_error: false)
      execute_command("git tag -d #{next_git_tag}")
    end

    if !execute_command('git diff --exit-code', raise_error: false)
      execute_command("git checkout Gemfile.lock #{changelog_path} #{version_file_path}")
    end

    exit(exit_code)
  end

  def print_changelog_content_of_upcoming_release
    logger.info('Changelog content for this upcoming release:')
    File.read(changelog_path)[/\A## Unreleased\n(?:(?!\n## ).)+/m].
      pipe('bat --color always --language markdown --style grid,numbers').
      then { puts(_1) }
  end

  def print_diff_since_last_release
    logger.info('Diff since the last release:')
    system(
      { 'DELTA_PAGER' => 'cat' },
      'git',
      'diff',
      "#{latest_tag}...",
    )
  end

  def file_path(file_name)
    system_output("find . -type f -name #{file_name}").delete_prefix('./')
  end

  def file_contents(file_path)
    File.read("#{ENV.fetch('PWD')}/#{file_path}")
  end

  def write_file(file_path, file_contents)
    File.write("#{ENV.fetch('PWD')}/#{file_path}", file_contents)
  end

  memo_wise \
  def version_file_path
    file_path('version.rb')
  end

  memo_wise \
  def changelog_path
    file_path('CHANGELOG.md')
  end

  memo_wise \
  def latest_tag
    `git tag -l 'v[0-9]*.[0-9]*.[0-9]*' | sort -V | tail -1`.rstrip
  end

  memo_wise \
  def current_released_version
    latest_tag.match(/v(\d.*)$/)&.[](1)
  end

  memo_wise \
  def current_version
    file_contents(version_file_path).match(/VERSION += +['"](?<version>.*)['"]/)&.
      named_captures&.to_h&.
      dig('version')
  end

  memo_wise \
  def next_version
    version_calculator.increment_for(@options[:type])
  end

  memo_wise \
  def version_calculator
    RungerReleaseAssistant::VersionCalculator.new(current_version:)
  end
end
