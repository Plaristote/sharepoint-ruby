module Sharepoint
  class List < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource
  end

  class ListItem < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :list
  end

  class View < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :list
  end
end
