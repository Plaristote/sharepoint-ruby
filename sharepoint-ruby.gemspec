Gem::Specification.new do |s|
  s.name         = 'sharepoint-ruby'
  s.version      = '0.0.1'
  s.date         = '2014-04-25'
  s.summary      = 'sharepoint client'
  s.description  = "Client for Sharepoint's REST API"
  s.authors      = ["Michael Martin Moro"]
  s.email        = 'michael@unetresgrossebite.com'
  s.files        = ['lib/sharepoint-ruby.rb',   'lib/sharepoint-session.rb',
                    'lib/sharepoint-object.rb', 'lib/sharepoint-types.rb',
                    'lib/sharepoint-users.rb',  'lib/sharepoint-lists.rb', 'lib/sharepoint-files.rb',
                    'lib/soap/authenticate.xml.erb']
  s.homepage     = 'https://github.com/Plaristote/sharepoint-ruby'
  s.license      = 'BSD'
  s.require_path = 'lib'

  s.add_runtime_dependency 'curb', '~> 0.8', '>= 0.8.5'
end
