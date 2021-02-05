# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'release_assistant/version'

Gem::Specification.new do |spec|
  spec.name          = 'release_assistant'
  spec.version       = ReleaseAssistant::VERSION
  spec.authors       = ['David Runger']
  spec.email         = ['davidjrunger@gmail.com']
  spec.summary       = 'Release gems with ease'
  spec.homepage      = 'https://github.com/davidrunger/release_assistant'
  spec.license       = 'MIT'
  spec.metadata['allowed_push_host'] = 'https://davidrunger.com'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/davidrunger/release_assistant'
  spec.metadata['changelog_uri'] =
    'https://github.com/davidrunger/release_assistant/blob/master/CHANGELOG.md'
  spec.files         = ['lib/release_assistant/version.rb']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7.0'
end
