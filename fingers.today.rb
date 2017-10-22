require "sinatra/base"
require "pathname"

require_relative "lib/renderable_file"

module ViewHelpers
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def current_page
    @current_page ||= RenderableFile.build(request.path[1..-1])
  end

  def breadcrumb_pages
    page = current_page
    pages = []
    while page = page.parent
      pages << page
    end
    pages.reverse[1..-1] || []
  end
end

class FingersToday < Sinatra::Base
  def authenticated?
    request.env["HTTP_X_CLIENT_AUTHENTICATED"] == "SUCCESS"
  end

  set :port, 6789

  helpers ViewHelpers

  get "/" do
    page = RenderableFile.build("_index")
    erb :index, locals: { page: page }
  end

  get "/*" do
    begin
      renderable_file = RenderableFile.build(params[:splat].first)
      if renderable_file.file?
        erb :page, locals: { page: renderable_file }
      elsif renderable_file.directory?
        erb :directory_index, locals: { index: renderable_file }
      elsif authenticated?
        erb :page, locals: { page: RenderableFile.build("_new_page_template") }
      else
        halt 404
      end
    rescue IllegalPagePath
      halt 400
    end
  end

  post "/" do
    return 401 unless authenticated?
    page = RenderableFile.build("_index")
    page.save(request.body.read.strip)
    200
  end

  post "/*" do
    return 401 unless authenticated?
    begin
      page = RenderableFile.build(params[:splat].first)
      page.save(request.body.read.strip)
      200
    rescue IllegalPagePath
      halt 400
    end
  end

  run! if app_file == $0
end
