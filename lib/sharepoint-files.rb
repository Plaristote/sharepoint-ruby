require 'open-uri'

module Sharepoint
  class Folder < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource get_from_name: 'GetFolderByServerRelativeUrl'

    field 'WelcomePage'
    field 'UniqueContentTypeOrder'

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

    def approve comment = '', checkintype = nil
      params  = "comment='#{URI.encode comment.gsub("'", %q(\\\'))}'"
      params += ",checkintype=#{checkintype}" unless checkintype.nil?
      @site.query :post, "#{__metadata['uri']}/approve(#{params})"
    end

    def deny comment = ''
      params  = "comment='#{URI.encode comment.gsub("'", %q(\\\'))}'"
      @site.query :post, "#{__metadata['uri']}/deny(#{params})"
    end

    def download
      @site.query :get, "#{__metadata['uri']}/$value"
    end

    def upload data
      @site.query :post, "#{__metadata['uri']}/$value", data do |curl|
        curl.headers['X-HTTP-Method'] = 'PUT'
      end
    end

    def upload_from_file filename
      content = String.new
      ::File.open filename, 'rb' do |file|
        line = nil
        content += line while line = file.gets
      end
      upload content
    end
  end

  class FileVersion < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :file
  end
end
