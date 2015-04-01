module Sharepoint
  LIST_TEMPLATE_TYPE = {
    InvalidType: -1,
    NoListTemplate: 0,
    GenericList: 100,
    DocumentLibrary: 101,
    Survey: 102,
    Links: 103,
    Announcements: 104,
    Contacts: 105,
    Events: 106,
    Tasks: 107,
    DiscussionBoard: 108,
    PictureLibrary: 109,
    DataSources: 110,
    UserInformation: 112,
    WebPartCatalog: 113,
    ListTemplateCatalog: 114,
    XMLForm: 115,
    MasterPageCatalog: 116,
    NoCodeWorkflows: 117,
    WorkflowProcess: 118,
    WebPageLibrary: 119,
    CustomGrid: 120,
    SolutionCatalog: 121,
    NoCodePublic: 122,
    ThemeCatalog: 123,
    DesignCatalog: 124,
    AppDataCatalog: 125,
    DataConnectionLibrary: 130,
    WorkflowHistory: 140,
    GanttTask: 150,
    HelpLibrary: 151,
    AccessRequest: 160,
    TasksWithTimelineAndHierarchy: 171,
    MaintenanceLogs: 175,
    Meetings: 200,
    Agenda: 201,
    MeetingUser: 202,
    Decision: 204,
    MeetingObjective: 207,
    TextBox: 210,
    ThingsToBring: 211,
    HomePageLibrary: 212,
    Posts: 301,
    Comments: 302,
    Categories: 303,
    Facility: 402,
    Whereabouts: 403,
    CallTrack: 404,
    Circulation: 405,
    Timecard: 420,
    Hollidays: 421,
    IMEDic: 499,
    ExternalList: 600,
    MySiteDocumentLibrary: 700,
    IssueTracking: 1100,
    AdminTasks: 1200,
    HealthRules: 1220,
    HealthReports: 1221,
    DeveloperSiteDraftApps: 1230,
    MicroFeed: 544 # Is undefined, but used by Sharepoint Online
  }

  class List < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource get_from_name: 'lists/getbytitle'

    def find_items options = {}
      url = @data['Items']['__deferred']
      has_options = false
      options.each do |key,value|
        url += if has_options then '&' else '?' end
        url += "$#{key}=#{URI::encode value.to_s}"
        has_options = true
      end
      @site.query :get, url
    end

    def item_count
      @site.query :get, "#{__metadata['id']}/ItemCount"
    end

    field 'BaseTemplate', access: [ :read, :initialize ], default: LIST_TEMPLATE_TYPE[:GenericList]
    field 'ContentTypesEnabled',                          default: true
    field 'DefaultContentApprovalWorkflowId'
    field 'DefaultDisplayFormUrl'
    field 'DefaultEditFormUrl'
    field 'DefaultNewFormUrl'
    field 'Description'
    field 'Direction'
    field 'DocumentTemplateUrl'
    field 'DraftVersionVisibility', default: 1
    field 'EnableAttachments',      default: false
    field 'EnableFolderCreation',   default: true
    field 'EnableMinorVersions',    default: true
    field 'EnableModeration',       default: true
    field 'EnableVersioning',       default: true
    field 'ForceCheckout',          default: false
    field 'Hidden',                 default: false
    field 'IrmEnabled',             default: false
    field 'IrmExpire',              default: false
    field 'IrmReject',              default: false
    field 'IsApplicationList',      default: false
    field 'MultipleDataList',       default: false
    field 'NoCrawl',                default: false
    field 'OnQuickLaunch',          default: false
    field 'Title'
    field 'ValidationFormula'
    field 'ValidationMessage'
  end

  class ListItem < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :list

    method :break_role_inheritance, default_params: ({ copyroleassignements: true })
    method :recycle
    method :reset_role_inheritance
    method :validate_update_item_list
  end

  class View < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :list

    field 'Aggregations'
    field 'AggregationsStatus'
    field 'ContentTypeId'
    field 'DefaultView'
    field 'DefaultViewForContentType'
    field 'EditorModified'
    field 'Formats'
    field 'Hidden'
    field 'IncludeRootFolder'
    #field 'JsLink'
    field 'ListViewXml'
    field 'Method'
    field 'MobileDefaultView'
    field 'MobileView'
    field 'Paged'
    field 'RowLimit'
    field 'Scope'
    field 'Title'
    field 'Toolbar'
    field 'ViewData'
    field 'ViewJoins'
    field 'ViewProjectedFields'
    field 'ViewQuery'

    method :break_role_inheritance, default_params: ({ copyroleassignements: true })
    method :recycle
    method :render_list_form_data
    method :reserve_list_item_id
  end

  class ViewFieldCollection < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource
    belongs_to :view

    def add_view_field name
      @site.query :post, "#{__metadata['uri']}/addviewfield('#{URI.encode name}')"
    end

    def move_view_field_to name, index
      @site.query :post, "#{__metadata['uri']}/moveviewfieldto", {
        field: name,
        index: index
      }.to_json
    end

    def remove_all_view_fields
      @site.query :post, "#{__metadata['uri']}/removeallviewfields"
    end

    def remove_view_field name
      @site.query :post, "#{__metadata['uri']}/removeviewfield('#{URI.encode name}')"
    end
  end
end
