require "pathname"

class IllegalPagePath < Exception; end

class Page
  class << self
    @directory_whitelist = []
    attr_reader :directory_whitelist
  end

  PAGES_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../pages")

  def initialize(path)
    @pathname = Pathname.new(PAGES_ROOT)
    @pathname += path
    check_path_is_safe!(@pathname)
  end

  def self.directory_whitelist=(directories)
    @directory_whitelist = directories.map do |dir|
      File.expand_path(dir)
    end
  end

  def save(content)
    File.open(@pathname, "w") do |f|
      f << content
    end
  end

  def content
    File.read(@pathname)
  end

  private

  def check_path_is_safe!(pathname)
    unless pathname.to_s.start_with?(*self.class.directory_whitelist)
      raise IllegalPagePath.new("#{pathname} is not in the directory whitelist")
    end
  end
end
