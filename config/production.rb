module EnvironmentConfig
  def authenticated?
    request.env["HTTP_X_CLIENT_AUTHENTICATED"] == "SUCCESS"
  end

  class << self
    def included(mod)
      mod.set :port, 6789
    end
  end
end
