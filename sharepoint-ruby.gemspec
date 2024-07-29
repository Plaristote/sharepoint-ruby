Gem::Specification.new do |s|
  s.name         = 'sharepoint-ruby'
  s.version      = '0.2.4'
  s.date         = '2024-05-13'
  s.summary      = 'sharepoint client'
  s.description  = "Client for Sharepoint's REST API"
  s.authors      = ["Michael Martin Moro"]
  s.email        = 'michael@unetresgrossebite.com'
  s.files        = Dir["lib/**/*", "MIT-LICENSE", "README.md"]
  s.homepage     = 'https://github.com/Plaristote/sharepoint-ruby'
  s.license      = '0BSD'
  s.require_path = 'lib'

  s.add_runtime_dependency 'curb'
end
