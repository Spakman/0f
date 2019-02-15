require "sinatra/base"
require "pathname"

require_relative "lib/renderable_file"
require_relative "lib/sync"
environment = %w( server localhost android ).detect(-> { "development" }) do |env|
  env == ENV["ZEROEFF_ENV"]
end
require_relative "config/#{environment}"


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


class ZeroEff < Sinatra::Base

  helpers ViewHelpers

  include EnvironmentConfig

  def process_get(uri_path)
    begin
      renderable_file = RenderableFile.build(uri_path, with_index_page: true)
      if renderable_file.file?
        erb :page, locals: { page: renderable_file }
      elsif authenticated?
        erb :page, locals: { page: RenderableFile.build("_new_page_template"), new_page: true }
      else
        halt 404
      end
    rescue IllegalPagePath
      halt 400
    end
  end

  get "/private/?*" do
    return 401 unless authenticated?
    process_get(File.join("private", params[:splat].first))
  end

  get "/*" do
    process_get(params[:splat].first)
  end

  delete "/*" do
    return 401 unless authenticated?
    begin
      page = RenderableFile.build(params[:splat].first)
      Sync.append_to_excludes(page.uri_path)
      page.delete!
      Thread.new { Sync.all }
      redirect(page.parent.uri_path)
    rescue IllegalPagePath
      halt 400
    end
  end

  put "/*" do
    return 401 unless authenticated?
    begin
      page = RenderableFile.build(params[:splat].first, with_index_page: true)
      Sync.append_to_excludes(page.uri_path) if request.env["HTTP_X_ZEROEFF_NEW_PAGE"]
      page.save(request.body.read.strip)
      Sync.all if request.env["HTTP_X_ZEROEFF_NEW_PAGE"]
      200
    rescue IllegalPagePath
      halt 400
    end
  end

  post "/_/wake-up" do
    return 401 unless authenticated?
    changed_files = Sync.all
    body = request.body.read
    body = body[1, body.length] if body[0] ==?/
    current_page = RenderableFile.build(body, with_index_page: true)
    if changed_files.include?(current_page.uri_path)
      200
    else
      204
    end
  end

  post "/_/finished-editing" do
    return 401 unless authenticated?
    Sync.all
  end

  post "/*" do
    return 401 unless authenticated?
    begin
      old_page = RenderableFile.build(request.body.read, with_index_page: false)
      new_uri_path = params[:splat].first
      Sync.append_to_excludes(old_page.uri_path, new_uri_path)
      old_page.move_to(new_uri_path)
      Thread.new { Sync.all }
      200
    rescue IllegalPagePath
      halt 400
    end
  end

  run! if app_file == $0
end
