module EnvironmentConfig
  def authenticated?
    true
  end

  class << self
    def included(mod)
      mod.set :port, 6789

      error_logger = File.new("#{File.expand_path(File.dirname(__FILE__))}/../log/error.log", "a+")
      error_logger.sync = true

      mod.before {
        env["rack.errors"] =  error_logger
      }

      Sync.const_set(:EXCLUDES_FILE_PATH, "/dev/null")

      def Sync.all; []; end
    end
  end
end
