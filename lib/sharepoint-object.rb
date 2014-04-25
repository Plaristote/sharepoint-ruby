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

module Sharepoint
  class Object
    def initialize site, data
      @site       = site
      @data       = data
      @properties = Hash.new
      initialize_properties
    end

  private
    def initialize_properties
      @data.each do |key,value|
        define_singleton_method key.underscore do
          get_property key
        end
      end
    end

    def get_property property_name
      data = @data[property_name]
      if not @properties[property_name].nil?
        @properties[property_name]
      elsif data.class == Hash
        if not data['__deferred'].nil?
          @properties[property_name] = get_deferred_property property_name
        else
          @properties[property_name] = make_object_from_response({ 'd' => data })
        end
      elsif not data.nil?
        @properties[property_name]   = data
      else
        raise "Property #{property_name} does not exist."
      end
    end

    def get_deferred_property property_name
      deferred_data = @data[property_name]['__deferred']
      uri           = deferred_data['uri'].gsub /^http.*\/_api\/web\//i, ''
      @site.query :get, uri
    end
  end
end
