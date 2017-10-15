require "pathname"

class IllegalPagePath < Exception; end

class RenderableFile
  class << self
    PAGES_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../pages")

    @directory_whitelist = []
    attr_reader :directory_whitelist

    def build(path)
      pathname = Pathname.new(PAGES_ROOT)
      pathname += path
      check_path_is_safe!(pathname)

      if File.directory?(pathname)
        DirectoryIndex.new(pathname)
      else
        Page.new(pathname)
      end
    end

    def directory_whitelist=(directories)
      @directory_whitelist = directories.map do |dir|
        File.expand_path(dir)
      end
    end

    protected :new

    protected def check_path_is_safe!(pathname)
      unless pathname.to_s.start_with?(*RenderableFile.directory_whitelist)
        raise IllegalPagePath.new("#{pathname} is not in the directory whitelist")
      end

      pathname.ascend do |path|
        next if path == pathname
        if File.file?(path)
          raise IllegalPagePath.new("Something in the path is a file, should be a directory")
        end
      end
    end
  end

  def file?
    File.file?(@pathname)
  end

  def directory?
    File.directory?(@pathname)
  end

  class Page < RenderableFile
    def initialize(path)
      @pathname = path
    end

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
    def initialize(path)
      @pathname = path
    end

    def directories
      %w( dir1 dir2 )
    end

    def files
      %w( file1 file2 )
    end
  end
end
