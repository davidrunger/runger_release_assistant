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
    if config_file_options.config_file_exists?
      logger.info("YOU ARE RUNNING THE RELEASE PROCESS WITH OPTIONS #{@options.to_h}!")
      logger.info("CURRENT VERSION IS #{current_version}")
      logger.info("NEXT VERSION WILL BE #{next_version}")
    else
      logger.warn(<<~WARNING.rstrip.yellow)
        WARNING: You have not created a `.release_assistant.yml` file yet!
        Therefore, release_assistant will do nothing and will exit.
      WARNING
      logger.info(<<~SOLUTION.rstrip.blue.bold)
        TIP: Execute `release --init` to create a `.release_assistant.yml` file.
      SOLUTION
    end
  end

  private

  memoize \
  def current_version
    version_file_path = `find . -type f -name version.rb`.delete_prefix('./').rstrip
    File.read("#{ENV['PWD']}/#{version_file_path}").
      match(/VERSION += +['"](?<version>.*)['"]/)&.
      named_captures&.to_h&.
      dig('version')
  end

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

  memoize \
  def config_file_options
    ReleaseAssistant::ConfigFileOptions.new
  end
end
