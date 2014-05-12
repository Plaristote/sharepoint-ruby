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
    sharepoint_resource get_from_name: 'getbytitle'

    field 'ContentTypesEnabled'
    field 'DefaultContentApprovalWorkflowId'
    field 'DefaultDisplayFormUrl'
    field 'DefaultEditFormUrl'
    field 'DefaultNewFormUrl'
    field 'Description'
    field 'Direction'
    field 'DocumentTemplateUrl'
    field 'DraftVersionVisibility'
    field 'EnableAttachment'
    field 'EnableFolderCreation'
    field 'EnableMinorVersions'
    field 'EnableModeration'
    field 'EnableVersioning'
    field 'ForceCheckout'
    field 'Hidden'
    field 'IrmEnabled'
    field 'IrmExpire'
    field 'IrmReject'
    field 'IsApplicationList'
    field 'MultipleDataList'
    field 'NoCrawl'
    field 'OnQuickLaunch'
    field 'Title'
    field 'ValidationFormula'
    field 'ValidationMessage'
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
