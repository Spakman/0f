require "sinatra/base"
require "pathname"

def authenticated?
  request.env["HTTP_X_CLIENT_AUTHENTICATED"] == "SUCCESS"
end

class Page
  PAGE_ROOT = "pages"

  def initialize(path)
    @pathname = Pathname.new(PAGE_ROOT)
    @pathname += path
    check_path_is_safe!(@pathname)
  end

  def save(content)
    check_content_is_safe!(content)
    File.open(@pathname, "w") do |f|
      f << content
    end
  end

  def content
    File.read(@pathname)
  end

  private

  def check_path_is_safe!(pathname)
  end

  def check_content_is_safe!(content)
  end
end

class FingersToday < Sinatra::Base
  get "/" do
    page = Page.new("index")
    erb :page, locals: { page: page }
  end

  post "/" do
    page = Page.new("index")
    page.save(request.body.read.strip)
    200
  end

  run! if app_file == $0
end
