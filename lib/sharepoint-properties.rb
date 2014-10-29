require 'sharepoint-stringutils'

module Sharepoint
  class ObjectProperties
    attr_accessor :site, :data, :updated_data

    def initialize site, data
      @site                      = site
      @data                      = data
      @updated_data              = Hash.new
      @properties                = Hash.new
      @properties_names          = Array.new
      @properties_original_names = Array.new
      initialize_properties
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

    def available_properties
      @properties_names
    end

    private

    def initialize_properties
      @initialize_properties = true
      # Create the properties defined for the Sharepoint type used
      self.class.fields.each do |field|
        add_property field[:name], field[:default] if field[:access].include? :read
      end
      # Set the values and create any missing properties from the OData object
      @data.dup.each do |key,value|
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
      # We don't know a priori what the fields are for a generic object, so leave the validation work to the user
      return true if self.is_a?(GenericSharepointObject)
        
      self.class.fields.each do |field|
        return field[:access].include? :write if field[:name] == property_name
      end
      false
    end
  end
end
