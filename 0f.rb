require "sinatra/base"
require "pathname"

environment = %w( server localhost ).detect(-> { "development" }) do |env|
  env == ENV["0F_ENV"]
end
require_relative "config/#{environment}"
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


class ZeroEff < Sinatra::Base

  helpers ViewHelpers

  include EnvironmentConfig

  def process_get(uri_path)
    begin
      renderable_file = RenderableFile.build(uri_path, with_index_page: true)
      if renderable_file.file?
        erb :page, locals: { page: renderable_file }
      elsif authenticated?
        erb :page, locals: { page: RenderableFile.build("_new_page_template") }
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
      page.delete!
      redirect(page.parent.uri_path)
    rescue IllegalPagePath
      halt 400
    end
  end

  put "/*" do
    return 401 unless authenticated?
    begin
      page = RenderableFile.build(params[:splat].first, with_index_page: true)
      page.save(request.body.read.strip)
      200
    rescue IllegalPagePath
      halt 400
    end
  end

  post "/*" do
    return 401 unless authenticated?
    begin
      old_page = RenderableFile.build(request.body.read, with_index_page: false)
      old_page.move_to(params[:splat].first)
      200
    rescue IllegalPagePath
      halt 400
    end
  end

  run! if app_file == $0
end
