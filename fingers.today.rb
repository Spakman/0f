require "sinatra/base"
require "pathname"

require_relative "lib/renderable_file"

RenderableFile.directory_whitelist = *"pages"

module ViewHelpers
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def link(text, *uri_parts)
    escaped_uri = URI::Parser.new.escape(File.join(uri_parts))
    %{<a href="#{escaped_uri}">#{h(text)}</a>}
  end
end

class FingersToday < Sinatra::Base
  def authenticated?
    request.env["HTTP_X_CLIENT_AUTHENTICATED"] == "SUCCESS"
  end

  set :port, 6789

  helpers ViewHelpers

  get "/" do
    page = RenderableFile.build("index")
    erb :page, locals: { page: page }
  end

  get "/*" do
    begin
      renderable_file = RenderableFile.build(params[:splat].first)
      if renderable_file.file?
        erb :page, locals: { page: renderable_file }
      elsif renderable_file.directory?
        erb :directory_index, locals: { index: renderable_file }
      elsif authenticated?
        halt 501, "This will be a new page"
      else
        halt 404
      end
    rescue IllegalPagePath
      halt 400
    end
  end

  post "/" do
    return 401 unless authenticated?
    page = RenderableFile.build("index")
    page.save(request.body.read.strip)
    200
  end

  run! if app_file == $0
end
