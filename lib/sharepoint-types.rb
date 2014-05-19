require 'sharepoint-object'

module Sharepoint
  class UnsupportedType < ::Exception
    attr_accessor :type_name

    def initialize type_name
      @type_name = type_name
    end

    def message
      "unsupported type '#{@type_name}'"
    end
  end

  module Type
    def initialize site, data = nil
      data               ||= Hash.new
      data['__metadata'] ||= {
        'type' => "SP.#{self.class.name.split('::').last}"
      }
      super site, data
    end
  end
end

require 'sharepoint-users'
require 'sharepoint-lists'
require 'sharepoint-files'
require 'sharepoint-fields'
require 'date'

module Sharepoint
  ##
  ## Sharepoint Management
  ##
  class Web < Sharepoint::Object
    include Sharepoint::Type

    field 'CustomMasterUrl'
    field 'Description'
    field 'EnableMinimalDownload'
    field 'MasterUrl'
    field 'QuickLaunchEnabled'
    field 'SaveSiteAsTemplateEnabled'
    field 'SyndicationEnabled'
    field 'Title'
    field 'TreeViewEnabled'
    field 'UiVersion'
    field 'UiVersionConfigurationEnabled'

    method :apply_theme
    method :break_role_inheritance, default_params: ({ clearsubscopes: true })
  end

  class ContextWebInformation < Sharepoint::Object
    include Sharepoint::Type

    def issued_time
      strtime = (form_digest_value.split ',').last
      DateTime.strptime strtime, '%d %b %Y %H:%M:%S %z'
    end

    def timeout_time
      issued_time + Rational(form_digest_timeout_seconds, 86400)
    end

    def is_up_to_date?
      DateTime.now < timeout_time
    end
  end

  ##
  ## Other types
  ##
  class PropertyValues < Sharepoint::Object
    include Sharepoint::Type
  end
end
