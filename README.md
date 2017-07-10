sharepoint-ruby
===============
A ruby gem that maps Sharepoint's REST API in a simple and accessible fashion.

How to use
===============
First, you'll have to initialize a sharepoint site and open a session in order to start making requests to the REST API:

```Ruby
require 'sharepoint-ruby'

site = Sharepoint::Site.new 'mysite.sharepoint.com', 'server-relative-site-url'
site.session.authenticate 'mylogin', 'mypassword'

blog = Sharepoint::Site.new 'mytenant.sharepoint.com', 'sites/blog'
blog.session.authenticate 'user', 'pwd'
lists = blog.lists
for l in lists
  puts l.title
end
```

Note that site.session.authenticate might throw an exception if the authentication doesn't go well (wrong urls, STS unavailable, or wrong login/password).
The exceptions might be of type ConnectionToStsFailed, AuthenticationFailed, ConnexionToSharepointFailed, UnknownAuthenticationError.

### Connecting to your own STS
By default, sharepoint-ruby uses Microsoft's STS (https://login.microsoftonline.com/extSTS.srf), which works for Sharepoint Online. You may use your own STS by using the optional third parameter of Sharepoint::Site.new:

```Ruby
site = Sharepoint::Site.new 'mysite.sharepoint.com', 'site-name'
site.session.authenticate  'username', 'password', 'https://sts_url.com/extSTS.srf'
```

### Connecting using NTLM
You may also connect using the NTLM method. For that purpose, you'll have to overwrite the default session handler with `Sharepoint::HttpAuth::Session`.

```Ruby
require 'sharepoint-http-auth'

site = Sharepoint::Site.new 'mysite.sharepoint.com', 'site-name'
site.session = Sharepoint::HttpAuth::Session.new site
site.session.authenticate 'login', 'password'
site.protocole = 'http' # default protocole is https: don't forget to set this if you use http.
```

### Connecting using Kerberos
You may also connect using Kerberos if you're using *MIT Kerberos*. 
For that purpose, you'll have to overwrite the default session handler with `Sharepoint::KerberosAuth::Session`.

```Ruby
require 'sharepoint-kerberos-auth'

site = Sharepoint::Site.new 'mysite.sharepoint.com', 'site-name'
site.session = Sharepoint::KerberosAuth::Session.new site
site.session.authenticate 'login', 'password'
site.protocole = 'http' # default protocole is https: don't forget to set this if you use http.
```

### General features

Once you're logged in, you may access the site's ressource through the site object:
```Ruby
fields  = site.fields # Get all the site's fields
groups  = site.groups # Get all the site's groups
users   = site.users  # Get all the site's users

lists = site.lists # Get all the site's list
list  = site.list 'Documents' # Get a list by title
list  = site.list '51925dd7-2108-481a-b1ef-4bfa4e69d48b' # Get a list by guid
views = list.views # Get all the lists views

folders = site.folders # Get all the site's folder
folder  = site.folder '/SiteAssets/documents' # Get a folder by server relative path
files   = folder.files # Get all the folder's files
```

### OData mapping
When Sharepoint answers with an OData object, the `site.query` method will automatically map it to the corresponding Sharepoint::Object class.
For instance, if Sharepoint answered with an OData object of type 'SP.List', `site.query` will return an instance of the Sharepoint::List class. These classes implement a getter and a setter for all the properties declared for the corresponding object in Sharepoint's 2013 Documentation.

N.B: Note that the setter only exists if the property is declared as write-accessible in the documentation.
N.B#2: Note that despite the camel casing used by Sharepoint, the getter and setter are snake cased (i.e: the CustomMasterUrl property becomes accessible through the custom_master_url getter and custom_mater_url= getter).

#### Sharepoint::Object specifics
Sharepoint::Object contains a few methods to help you handle your objects:

The `guid` method can be used to retrieve the guid of any object.

The `reload` method returns an instance of the same object from the remote sharepoint site. It may be useful if you want to be sure that your object contains the latest changes.

The `save` method will automatically compile your changes and perform the MERGE request with the Sharepoint site.

The `destroy` method will destroy the remote ressource on the Sharepoint site.

The `copy` method can duplicate an existing object. If you send it a Sharepoint::Object as a parameter, it will duplicate into the parameter. If you don't send any parameter, it will create a new object. Note that no changes happen on the sharepoint site until you've called the `save` method on the returned object.

### Deferred objects
Some of the properties of the OData object are 'deferred', which means that the property only provides a link to a ressource that you would have to get for yourself.
Not with the sharepoint-ruby gem however: the first time you try to access a deferred property, the object will on it's own go look for the corresponding remote ressource: the result will be stored for later uses, and then be returned to you.

### Modifying Sharepoint's ressources
The Sharepoint REST API provides us with methods to create, update or delete resources. In the Sharepoint::Object, these behaviours are implemented through the save and delete methods.

##### Updating objects
This piece of code will change the custom master page used by the Sharepoint site to 'oslo.master':
```Ruby
  web = site.context_info # Sharepoint::Site.context_info returns the Web object for the current site (see: http://msdn.microsoft.com/en-us/library/office/dn499819(v=office.15).aspx )
  web.custom_master_url = '/_catalogs/masterpage/oslo.master'
  web.save
```

##### Creating objects
You may also create your own objects. This will be slightly different: we will create our own instance of a Sharepoint::List object.
Some Sharepoint objects have values that can only be set during their initialization: `sharepoint-ruby` doesn't allow you to set these values through a setter.
In the case of list, Sharepoint will require you to specify the value for the `BaseTemplate` property. This is how you would specify the default value for an attribute that isn't write-accessible:
```Ruby
  list             = Sharepoint::List.new site, { 'BaseTemplate' => Sharepoint::LIST_TEMPLATE_TYPE[:GenericList] }
  list.title       = 'My new list'
  list.description = 'A list created by sharepoint-ruby'
  list             = list.save # At creation, the remote object created will be returned by the save method.
```
Note that the attribute's name in the constructor remains camel cased (`BaseTemplate`), though the getter for this attribute is still snake cased (`base_template`).

##### Destroying objects
Now, say you want to destroy the list you just created, this will do nicely:
```Ruby
  list.destroy
```

### Parenting
In the previous paragraph, we saw how to create a Sharepoint::List object. Sharepoint lists aren't parented to any other objects: Sharepoint views however are parented to a list. If you wanted to create a view for the list we just created, you would have to specify a parent for the view:

```Ruby
  view               = Sharepoint::View.new site
  view.title         = 'My new view'
  view.personal_view = false
  view.parent        = list # Setting the view's parent to the Sharepoint::List
  view.save
```

### Collections
In sharepoint-ruby, collections are merely arrays of Sharepoint::Objects. If you wish to add an object to a colleciton, set the parent to the object providing the collection.

### List Items
Sharepoint doesn't allow the user to fetch more than 100 items per query. When your list contains more than a 100 items, you may fetch them using the `find_items` method:

```Ruby
  list = site.list 'My List'
  # Use the skip option to paginate
  list.find_items skip: 50 # returns items from 50-150
  # You may use other operators in your query, such as orderby, select, filter and top:
  list.find_items skip: 100, orderby: 'Title asc'
```

### Exceptions
Inevitably, some of your requests will fail. The object sharepoint returns when an error happens is also mapped by sharepoint-ruby in the Sharepoint::SPException class.
The SPException class contains methods to inspect the query that was made to the server:

```Ruby
  begin
    list = site.list 'title that does not exists'
  rescue Sharepoint::SPException => e
    puts "Sharepoint complained about something: #{e.message}"
    puts "The action that was being executed was: #{e.uri}"
    puts "The request had a body: #{e.request_body}" unless e.request_body.nil?
  end
```
