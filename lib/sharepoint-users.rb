module Sharepoint
  class Group < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource getter: :sitegroups
  end

  class User < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource getter: :siteusers
    belongs_to :group
  end

  class UserCustomAction < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource
  end

  class RoleAssignment < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource
  end

  class RoleDefinition < Sharepoint::Object
    include Sharepoint::Type
  end

  class GenericSharepointObject < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource

    def initialize type_name, site, data
      super site, data
      @generic_type_name = type_name
    end
  end
end
