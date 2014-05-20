require 'open-uri'

module Sharepoint
  class Folder < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource get_from_name: 'GetFolderByServerRelativeUrl'

    field 'WelcomePage'
    field 'UniqueContentTypeOrder'

    method :recycle

    def file_from_name name
      @site.query :get, "#{__metadata['uri']}/files/getbyurl('#{name}')"
    end

    def add_file name, content
      uri = "#{__metadata['uri']}/files/add(overwrite=true,url='#{name}')"
      @site.query :post, uri, content
    end

    def add_folder name
      uri  = "#{__metadata['uri']}/folders"
      body = { '__metadata' => { 'type' => 'SP.Folder' }, 'ServerRelativeUrl' => name }
      @site.query :post, uri, body.to_json
    end
  end

  class File < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :folder
    sharepoint_resource getter: 'GetFileByServerRelativeUrl', no_root_collection: true

    method :approve,                     default_params: ({ comment: '' })
    method :deny,                        default_params: ({ comment: '' })
    method :checkin,                     default_params: ({ comment: '', checkintype: 0 })
    method :checkout
    method :undo_checkout
    method :copy_to,                     default_params: ({ overwrite: true })
    method :move_to,                     default_params: ({ flags: 9 })
    method :get_limited_webpart_manager, default_params: ({ scope: 0 }), http_method: :get
    method :download,                    endpoint: '$value',             http_method: :get
    method :upload,                      endpoint: '$value',             http_method: :put
    method :publish,                     default_params: ({ comment: '' })
    method :unpublish,                   default_params: ({ comment: '' })
    method :recycle

    def upload_from_file filename
      content = String.new
      ::File.open filename, 'rb' do |file|
        line = nil
        content += line while line = file.gets
      end
      upload content
    end

    def download_to_file filename
      content = download
      ::File.open filename, 'w' do |file|
        file.write content
      end
    end
  end

  class FileVersion < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :file
  end
end
