require 'open-uri'
require 'securerandom'

module Sharepoint
  class Folder < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource get_from_name: 'GetFolderByServerRelativeUrl'

    field 'WelcomePage'
    field 'UniqueContentTypeOrder'

    method :recycle

    def file_from_name name
      @site.query :get, "#{__metadata['uri']}/files/getbyurl('#{URI::encode(name.to_s)}')"
    end

    def add_file name, content
      uri = "#{__metadata['uri']}/files/add(overwrite=true,url='#{URI::encode(name.to_s)}')"
      @site.query :post, uri, content
    end

    def add_folder name
      uri  = "#{__metadata['uri']}/folders"
      body = { '__metadata' => { 'type' => 'SP.Folder' }, 'ServerRelativeUrl' => name.to_s }
      @site.query :post, uri, body.to_json
    end

    def add_file_via_streaming name, file
      add_file name, nil
      spo_file = file_from_name name
      spo_file.upload_file_via_streaming file
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
    method :download,                    endpoint: '$value',             http_method: :get, skip_json: true
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
      ::File.open filename, "w:#{content.encoding.name}" do |file|
        file.write content
      end
    end

    def upload_file_via_streaming file
      uuid = SecureRandom.uuid
      bytes_written = 0
      ::File.open(file) do |fh|
        while data = fh.read(10 * 1024 * 1024) do
          uri = (bytes_written == 0) ? "#{__metadata['uri']}/startupload(uploadId=guid'#{uuid}')" : "#{__metadata['uri']}/continueupload(uploadId=guid'#{uuid}',fileOffset=#{bytes_written})"
          result = @site.query :post, uri, data, skip_json: true
          new_position = (JSON.parse(result).dig('d', 'ContinueUpload') || JSON.parse(result).dig('d', 'StartUpload')).to_i
          bytes_written += data.size
          if new_position != bytes_written
            raise Exception.new("Streamed #{bytes_written} bytes data, but sharepoint reports position #{new_position}")
          end
        end
      end
      uri = "#{__metadata['uri']}/finishupload(uploadId=guid'#{uuid}',fileOffset=#{bytes_written})"
      result = @site.query :post, uri, nil, skip_json: true
    end
  end

  class FileVersion < Sharepoint::Object
    include Sharepoint::Type
    belongs_to :file
  end
end
