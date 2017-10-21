require "pathname"

class IllegalPagePath < StandardError; end

class RenderableFile
  attr_reader :uri_path, :basename

  PAGES_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../pages")

  class << self
    protected :new

    protected def check_path_is_safe!(pathname)
      unless pathname.to_s.start_with?(PAGES_ROOT)
        raise IllegalPagePath.new("#{pathname} is not in the pages directory: #{PAGES_ROOT}")
      end

      pathname.ascend do |path|
        next if path == pathname
        if File.file?(path)
          raise IllegalPagePath.new("Something in the path is a file, should be a directory")
        end
      end
    end
  end

  def self.build(uri_path)
    pathname = (Pathname.new(PAGES_ROOT) + uri_path).expand_path
    check_path_is_safe!(pathname)

    if File.directory?(pathname)
      DirectoryIndex.new(pathname)
    else
      Page.new(pathname)
    end
  end

  def initialize(pathname)
    @pathname = pathname
    if @pathname.to_s.index(PAGES_ROOT) == 0
      if @pathname.to_s.length > PAGES_ROOT.length
        @uri_path = @pathname.to_s[(PAGES_ROOT.length)..-1]
        @basename = pathname.basename.to_s
      else
        @uri_path = ?/
        @basename = ?/
      end
    end
  end

  def file?
    File.file?(@pathname)
  end

  def directory?
    File.directory?(@pathname)
  end

  def parent
    RenderableFile.build(@pathname.dirname)
  rescue IllegalPagePath
    nil
  end


  class Page < RenderableFile
    def save(content)
      File.open(@pathname, "w") do |f|
        f << content
      end
    end

    def content
      File.read(@pathname)
    end
  end


  class DirectoryIndex < RenderableFile
    def directories
      @pathname.children.select(&:directory?).map do |path|
        RenderableFile.build(path.expand_path)
      end
    end

    def pages
      pages = @pathname.children.select(&:file?).map do |path|
        RenderableFile.build(path.expand_path)
      end
      pages.delete_if { |p| p.basename[0] == ?_ }
    end
  end
end
