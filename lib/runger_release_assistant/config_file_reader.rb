# frozen_string_literal: true

class RungerReleaseAssistant::ConfigFileReader
  extend Memoist

  memoize \
  def options_hash
    if config_file_exists?
      YAML.load_file(config_file_path).symbolize_keys
    else
      {}
    end
  end

  private

  memoize \
  def config_file_path
    "#{ENV.fetch('PWD')}/.release_assistant.yml"
  end

  def config_file_exists?
    File.exist?(config_file_path)
  end
end
