require "sinatra/base"
require "pathname"

require_relative "lib/page"

Page.directory_whitelist = *"pages"

class FingersToday < Sinatra::Base
  def authenticated?
    request.env["HTTP_X_CLIENT_AUTHENTICATED"] == "SUCCESS"
  end

  set :port, 6789

  get "/" do
    page = Page.new("index")
    erb :page, locals: { page: page }
  end

  post "/" do
    return 401 unless authenticated?
    page = Page.new("index")
    page.save(request.body.read.strip)
    200
  end

  run! if app_file == $0
end
