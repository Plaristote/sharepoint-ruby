module Sharepoint
  class Group < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource getter: :sitegroups, get_from_name: 'sitegroups/getbyname'

    def create_uri ; 'sitegroups' ; end
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
end
