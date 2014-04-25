sharepoint-ruby
===============
A ruby client for Sharepoint's REST API.
Still a work in progress.

How to use
===============
First, you'll have to initialize a sharepoint site and open a session in order to start making requests to the REST API:

```Ruby
site = Sharepoint::Site.new 'mysite.sharepoint.com', 'site-name'
site.session.authenticate 'mylogin', 'mypassword'
```

Note that site.session.authenticate might throw an exception if the authentication doesn't go well (wrong urls, STS unavailable, or wrong login/password).
The exceptions might be of type ConnectionToStsFailed, AuthenticationFailed, ConnexionToSharepointFailed, UnknownAuthenticationError.


Once you're logged in, you may use any method method of Sharepoint's REST API using something such as this:
```Ruby
require 'open-uri'

directory_path = URI.encode "/site-name/Shared folders"
result = site.query :get, "GetFolderByServerRelativeUrl('#{directory_path}')"
```
Note that you must encode the URL yourself when it's relevant. Open-uri does the job just fine.
This snippet of code will return a Sharepoint::Object, which is an object mapped with the attributes of the object Sharepoint answered with.
The mapping converts the attribute's name from Sharepoint's Camelcase to Ruby's more standard snake case. If you want to access to the folders name, instead of using 'result.Name', you'll need to use 'result.name'.

It's not yet complete (no save/refresh method), but it does a few things.
For instance, it will dynamically load any attribute that is set as '__refered' in Sharepoint's answer. This means you can do things such as:
```Ruby
require 'open-uri'

directory_path = URI.encode "/site-name/Shared folders"
result = site.query :get, "GetFolderByServerRelativeUrl('#{directory_path}')"
result.files.count
```

Files aren't directly included in the answer to GetFolderByServerRelativeUrl: however, Sharepoint::Object will lazy-load them if you ask for them.
Note that since Sharepoint answers with a collection in that case, 'result.files' returns an array of Sharepoint::Object, instead of a Sharepoint::Object.

[WIP: In the future, Array will be replaced by an object of our own, Sharepoint::Collection, which will allow to add and remove objects from a collection and save the changes to Sharepoint]
