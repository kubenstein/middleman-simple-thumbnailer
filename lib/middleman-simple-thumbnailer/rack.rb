require 'rack/utils'
require 'cgi'

module MiddlemanSimpleThumbnailer
  class Rack
    def initialize(app, options= {}, middleman_app, config)
      @app = app
      @options = options
      @config = config
      @middleman_app = middleman_app
    end

    def call(env)
      path_info = env["PATH_INFO"]
      query_str = env["QUERY_STRING"]
      environment = @middleman_app.config[:environment]
      status = -1
      
      if(environment === :development && !query_str.empty?)
        query_hash = CGI::parse(query_str)
        if(query_hash.key?('simple-thumbnailer'))
            path, resize_to = query_hash['simple-thumbnailer'][0].split('|')
            image = MiddlemanSimpleThumbnailer::Image.new(path, resize_to, @middleman_app, @config)
            status = 200
            file_data = image.render
            headers = {
                "Content-Length" => file_data.bytesize.to_s,
                "Content-Type" => image.mime_type
            }
            response = [file_data]
        end
      end

      if status === -1
        status, headers, response = @app.call(env)
      end

      [status, headers, response]
    end
  
  end
end