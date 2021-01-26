# frozen_string_literal: true

class ReleaseAssistant::ConfigFileOptions
  def initialize
    @options =
      if config_file_exists?
        YAML.load_file(config_file_path)
      else
        {}
      end
  end

  def config_file_exists?
    File.exist?(config_file_path)
  end

  private

  def config_file_path
    "#{ENV['PWD']}/.release_assistant.yml"
  end
end
