require_relative 'lib/sharepoint-version'

Gem::Specification.new do |s|
  s.name = 'proof-sharepoint-ruby'
  s.version = Sharepoint::VERSION
  s.date = '2020-12-07'
  s.summary = 'SharePoint client.'
  s.description = "Client for Sharepoint's REST API forked from https://github.com/Plaristote/sharepoint-ruby"
  s.authors = ['Marlen Brunner']
  s.email = 'mbrunner@proofgov.com'
  s.homepage = 'https://github.com/proofgov/sharepoint-ruby'
  s.license = 'BSD'

  s.required_ruby_version = Gem::Requirement.new('>= 2.6.0')
  s.metadata['homepage_uri'] = s.homepage
  s.metadata['source_code_uri'] = 'https://github.com/proofgov/sharepoint-ruby'
  s.metadata['changelog_uri'] = 'https://github.com/proofgov/sharepoint-ruby/blob/master/CHANGELOG.md'

  s.require_path = 'lib'
  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.add_runtime_dependency 'curb', '~> 0.8', '<= 0.9.10'
end
