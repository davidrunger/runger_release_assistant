# frozen_string_literal: true

class RungerReleaseAssistant::ConfigFileReader
  prepend MemoWise

  memo_wise \
  def options_hash
    if config_file_exists?
      YAML.load_file(config_file_path).symbolize_keys
    else
      {}
    end
  end

  private

  memo_wise \
  def config_file_path
    "#{ENV.fetch('PWD')}/.release_assistant.yml"
  end

  def config_file_exists?
    File.exist?(config_file_path)
  end
end
