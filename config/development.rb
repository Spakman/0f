module EnvironmentConfig
  def authenticated?
    true
  end

  class << self
    def included(mod)
      mod.set :port, 6789
      mod.set :bind, "0.0.0.0"
    end
  end
end
