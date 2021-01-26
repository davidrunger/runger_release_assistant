# frozen_string_literal: true

class ReleaseAssistant::VersionCalculator
  extend Memoist

  def initialize(current_version:)
    @current_version = current_version
  end

  def increment_for(type)
    new_parts =
      case type
      when 'major'
        [major + 1, 0, 0]
      when 'minor'
        [major, minor + 1, 0]
      when 'patch'
        [major, minor, patch + 1]
      end
    new_parts.map(&:to_s).join('.')
  end

  private

  memoize \
  def parts
    @current_version.split('.').first(3).map { Integer(_1) }
  end

  memoize \
  def major
    parts[0]
  end

  memoize \
  def minor
    parts[1]
  end

  memoize \
  def patch
    parts[2]
  end
end
