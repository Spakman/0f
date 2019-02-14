module Sync
  def self.append_to_excludes(*paths)
    File.open(Sync::EXCLUDES_FILE_PATH, "a+") do |f|
      paths.each do |path|
        if path[0] != ?/
          path = "/#{path}"
        end
        f.puts path
      end
    end
  end

  def self.all
    fail "Sync.all must be explicitly redefined in each config/ file."
  end
end
