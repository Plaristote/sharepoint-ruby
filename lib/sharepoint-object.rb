unless String.new.methods.include? :underscore
  class String
    def underscore
      self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end

unless String.new.methods.include? :pluralize
  class String
    def pluralize
      if self.match /y$/
        self.gsub /y$/, 'ies'
      elsif self.match /us$/
        self.gsub /us$/, 'i'
      else
        self + 's'
      end
    end
  end
end

module Sharepoint
  class Site
  end

  class Object
    attr_accessor :site

    class << self
      attr_accessor :fields

      def fields
        parent_fields = if self.superclass != Sharepoint::Object
          self.superclass.fields
        else
          []
        end
        @fields ||= []
        parent_fields.concat @fields
      end

      def field name, options = {}
        options[:access] ||= [ :read, :write ]
        @fields ||= []
        @fields << { name: name, access: options[:access], default: options[:default] }
      end

      def sharepoint_resource options = {}
        options[:method_name]   ||= (self.name).split('::').last.downcase + 's'
        options[:getter]        ||= options[:method_name]
        options[:get_from_name] ||= options[:getter]
        Sharepoint::Site.send :define_method, options[:method_name] do
          self.query :get, options[:method_name].to_s
        end unless options[:no_root_collection] == true
        Sharepoint::Site.send :define_method, (self.name).split('::').last.downcase do |id|
          if id =~ /^[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}$/
            self.query :get, "#{options[:getter]}(guid'#{id}')"
          else
            self.query :get, "#{options[:get_from_name]}('#{URI.encode id}')"
          end
        end
      end

      def belongs_to resource_name
        resource_name = resource_name.to_s
        klass_name    = (self.name).split('::').last
        method_name   = klass_name.downcase + 's'
        define_singleton_method "all_from_#{resource_name}" do |resource|
          resource.site.query :get, "#{resource.__metadata['uri']}/#{method_name}"
        end
        define_singleton_method "get_from_#{resource_name}" do |resource, name|
          resource.site.query :get, "#{resource.__metadata['uri']}/#{method_name}('#{URI.encode name}')"
        end
      end
    end

    attr_accessor :data, :updated_data

    def initialize site, data
      @site                      = site
      @data                      = data
      @updated_data              = Hash.new
      @properties                = Hash.new
      @properties_names          = Array.new
      @properties_original_names = Array.new
      initialize_properties
    end

    def guid
      return @guid unless @guid.nil?
      __metadata['id'].scan /guid'([^']+)'/ do ||
        @guid = $1
        break
      end
      @guid
    end

    def available_properties
      @properties_names.dup
    end

    def add_property property, value = nil
      editable                = is_property_editable? property
      property                = property.to_s
      @data[property]         = nil   if @data[property].nil?
      @data[property]         = value unless value.nil?
      @updated_data[property] = value if (@initialize_properties == false) and (editable == true)
      unless @properties_original_names.include? property
        @properties_names          << property.underscore.to_sym
        @properties_original_names << property
        define_singleton_method property.underscore do
          get_property property
        end
        define_singleton_method property.underscore + '=' do |new_value|
          @data[property]         = new_value
          @updated_data[property] = new_value
        end if editable == true
      end
    end

    def add_properties properties
      properties.each do |property|
        add_property property
      end
    end

    def save
      if @data['__metadata'].nil? or @data['__metadata']['id'].nil?
        create
      elsif @updated_data.keys.count > 0
        update
      end
    end

    def destroy
      @site.query :post, relative_uri do |curl|
        curl.headers['X-HTTP-Method'] = 'DELETE'
        curl.headers['If-Match']      = __metadata['etag']
      end
    end

  private
    def sharepoint_typename
      self.class.name.split('::').last
    end

    def create
      @site.query :post, sharepoint_typename.pluralize.downcase, @data.to_json do |curl|
      end
    end

    def update
      @updated_data['__metadata'] ||= @data['__metadata']
      @site.query :post, relative_uri, @updated_data.to_json do |curl|
        curl.headers['X-HTTP-Method'] = 'MERGE'
        curl.headers['If-Match']      = __metadata['etag']
      end
      @updated_data = Hash.new
    end

    def relative_uri
      @data['__metadata']['uri'].gsub /^https:\/\/[^\/]+\/_api\/web\//i, ''
    end

    def initialize_properties
      @initialize_properties = true
      @data.each do |key,value|
        add_property key, value
      end
      @initialize_properties = false
    end

    def get_property property_name
      data = @data[property_name]
      if not @properties[property_name].nil?
        @properties[property_name]
      elsif data.class == Hash
        if not data['__deferred'].nil?
          @properties[property_name] = get_deferred_property property_name
        elsif not data['__metadata'].nil?
          @properties[property_name] = @site.make_object_from_data data
        else
          @properties[property_name] = data
        end
      elsif not data.nil?
        @properties[property_name]   = data
      else
        @properties[property_name]   = nil
      end
    end

    def get_deferred_property property_name
      deferred_data = @data[property_name]['__deferred']
      uri           = deferred_data['uri'].gsub /^http.*\/_api\/web\//i, ''
      @site.query :get, uri
    end

    def is_property_editable? property_name
      self.class.fields.each do |field|
        return field[:access].include? :write if field[:name] == property_name
      end
      false
    end
  end
end
