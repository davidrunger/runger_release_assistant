# frozen_string_literal: true

class RungerReleaseAssistant::VersionCalculator
  prepend MemoWise

  def initialize(current_version:)
    @current_version = current_version
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def increment_for(type)
    new_parts =
      case type
      when 'major'
        if modifier.present? && (minor == 0) && (patch == 0)
          # e.g. going from `2.0.0.alpha` to `2.0.0`
          [major, minor, patch]
        else
          # e.g. going from `2.3.4` to `3.0.0`
          [major + 1, 0, 0]
        end
      when 'minor'
        if modifier.present? && (patch == 0)
          # e.g. going from `0.4.0.alpha` to `0.4.0`
          [major, minor, patch]
        else
          # e.g. going from `0.3.3` to `0.4.0`
          [major, minor + 1, 0]
        end
      when 'patch'
        if modifier.present?
          # e.g. going from `0.3.3.alpha` to `0.3.3`
          [major, minor, patch]
        else
          # e.g. going from `0.3.3` to `0.3.4`
          [major, minor, patch + 1]
        end
      end
    new_parts.map(&:to_s).join('.')
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  memo_wise \
  def modifier
    @current_version.split('.')[3]
  end

  memo_wise \
  def parts
    @current_version.split('.').first(3).map { Integer(_1) }
  end

  memo_wise \
  def major
    parts[0]
  end

  memo_wise \
  def minor
    parts[1]
  end

  memo_wise \
  def patch
    parts[2]
  end
end
