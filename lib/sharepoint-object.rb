require 'sharepoint-properties'
require 'sharepoint-stringutils'

module Sharepoint
  class Site
  end

  class Object < Sharepoint::ObjectProperties
    class << self
      attr_accessor :fields

      def fields
        @fields ||= []
        if self.superclass != Sharepoint::Object
          self.superclass.fields | @fields
        else
          @fields
        end
      end

      protected

      def field name, options = {}
        options[:access] ||= [ :read, :write ]
        @fields ||= []
        @fields << { name: name, access: options[:access], default: options[:default] }
      end

      def method name, method_params = {}
        method_params[:http_method]    ||= :post
        method_params[:endpoint]       ||= name.to_s.camelize
        method_params[:default_params] ||= Hash.new
        define_method name, ->(params = Hash.new) do
          action = "#{__metadata['uri']}/#{method_params[:endpoint]}"
          body   = nil
          # Set default parameters
          (method_params[:default_params].each do |key,value|
            params[key] == value if params[key].nil?
          end)
          if (method_params[:http_method] == :get) and (params.class < Hash) and (params.keys.count > 0)
            # if method is get, Fill action with parameters
            action     += '('
            (params.each do |key,value|
              action += ',' unless params.keys.first == key
              action += key + '='
              action += (if (value.class < String) or (value.class < Symbol)
               "'#{(CGI.escape value.gsub("'", %q(\\\')))}'"
              else
                value
              end)
            end)
            action += ')'
          else
            # if method is post, send parameters in the body
            body = (params.class < Hash ? params.to_json : params)
          end
          # Call action
          @site.query method_params[:http_method], action, body, method_params[:skip_json]
        end
      end

      def sharepoint_resource options = {}
        options[:method_name]   ||= (self.name).split('::').last.downcase + 's'
        options[:getter]        ||= options[:method_name]
        options[:get_from_name] ||= options[:getter]
        Sharepoint::Site.send :define_method, options[:method_name] do
          self.query :get, options[:getter].to_s
        end unless options[:no_root_collection] == true
        Sharepoint::Site.send :define_method, (self.name).split('::').last.downcase do |id|
          if id =~ /^[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}$/
            self.query :get, "#{options[:getter]}(guid'#{id}')"
          else
            self.query :get, "#{options[:get_from_name]}('#{CGI.escape id}')"
          end
        end
      end

      def belongs_to resource_name
        resource_name = resource_name.to_s
        class_name    = (self.name).split('::').last.downcase
        method_name   = class_name.pluralize
        define_singleton_method "all_from_#{resource_name}" do |resource|
          resource.site.query :get, "#{resource.__metadata['uri']}/#{method_name}"
        end
        define_singleton_method "get_from_#{resource_name}" do |resource, name|
          resource.site.query :get, "#{resource.__metadata['uri']}/#{method_name}('#{CGI.escape name}')"
        end
        define_method "create_uri" do
          unless self.parent.nil?
            "#{self.parent.__metadata['uri']}/#{method_name}"
          else
            method_name
          end
        end
      end
    end

    attr_accessor :parent

    def initialize site, data
      @parent = nil
      super site, data
    end

    def guid
      return @guid unless @guid.nil?
      __metadata['id'].scan(/guid'([^']+)'/) do ||
        @guid = $1
        break
      end
      @guid
    end

    def reload
      @site.query :get, __metadata['uri']
    end

    def save
      if @data['__metadata'].nil? or @data['__metadata']['id'].nil?
        create
      elsif @updated_data.keys.count > 0
        update
      end
    end

    def destroy
      @site.query :post, resource_uri do |curl|
        curl.headers['X-HTTP-Method'] = 'DELETE'
        curl.headers['If-Match']      = __metadata['etag']
      end
    end

    def copy new_object = nil
      updating     = !new_object.nil?
      new_object ||= self.class.new @site
      self.class.fields.each do |field|
        next unless @data.keys.include? field[:name].to_s
        next if (field[:access] & [ :write, :initialize ]).count == 0
        value = @data[field[:name].to_s]
        if updating == false
          new_object.data[field[:name].to_s]         = value
        elsif new_object.data[field[:name].to_s] != value
          new_object.updated_data[field[:name].to_s] = value
        end
      end
      new_object
    end

  private
    def sharepoint_typename
      if self.is_a?(Sharepoint::GenericSharepointObject)
        @generic_type_name
      else
        self.class.name.split('::').last
      end
    end

    def resource_uri
      @data['__metadata']['uri'].gsub(/^https:\/\/[^\/]+\/_api\/web\//i, '')
    end

    def create_uri
      sharepoint_typename.downcase.pluralize
    end

    def create
      @site.query :post, create_uri, @data.to_json
    end

    def update
      @updated_data['__metadata'] ||= @data['__metadata']
      @site.query :post, resource_uri, @updated_data.to_json do |curl|
        curl.headers['X-HTTP-Method'] = 'MERGE'
        curl.headers['If-Match']      = __metadata['etag']
      end
      @updated_data = Hash.new
    end
  end
end
