require "pathname"

class IllegalPagePath < StandardError; end

class RenderableFile
  attr_reader :uri_path, :basename, :pathname

  PAGES_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../pages")
  PRIVATE_PAGES_ROOT = File.join(PAGES_ROOT, "private")

  class << self
    protected :new

    def check_path_is_safe!(pathname)
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

  def self.build(uri_path, with_index_page: false)
    pathname = (Pathname.new(PAGES_ROOT) + uri_path).expand_path
    check_path_is_safe!(pathname)

    if File.directory?(pathname)
      if with_index_page
        index_page_pathname = pathname + "_"
        FileUtils.touch(index_page_pathname) unless File.exist?(index_page_pathname)
        Page.new(pathname + "_")
      else
        DirectoryIndex.new(pathname)
      end
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

  def delete!
    if deletable?
      @pathname.delete
    else
      fail IllegalPagePath.new
    end
  end

  def file?
    File.file?(@pathname)
  end

  def directory?
    File.directory?(@pathname)
  end

  def private?
    @pathname.to_s.start_with?(PRIVATE_PAGES_ROOT)
  end

  def root?
    if directory?
      @pathname.to_s == PAGES_ROOT
    else
      @pathname.dirname.to_s == PAGES_ROOT && @basename == ?_
    end
  end

  def private_root?
    if directory?
      @pathname.to_s == PRIVATE_PAGES_ROOT
    else
      @pathname.dirname.to_s == PRIVATE_PAGES_ROOT && @basename == ?_
    end
  end

  def movable?
    @pathname.exist? && !root? && !private_root?
  end

  def exist?
    @pathname.exist?
  end

  def parent
    RenderableFile.build(@pathname.dirname)
  rescue IllegalPagePath
    nil
  end

  def move_to(new_path)
    if movable?
      new_renderable_file = RenderableFile.build(new_path)
      if new_renderable_file.exist?
        raise IllegalPagePath.new
      else
        self.class.check_path_is_safe!(new_renderable_file.pathname)
        FileUtils.mkdir_p(new_renderable_file.pathname.dirname)
        begin
          FileUtils.mv(@pathname, new_renderable_file.pathname)
        rescue ArgumentError
          raise IllegalPagePath.new
        end
      end
    else
      raise IllegalPagePath.new
    end
  end


  class Page < RenderableFile
    def save(content)
      FileUtils.mkdir_p(@pathname.dirname, mode: 02770)
      File.open(@pathname, "w", 0660) do |f|
        f << content
      end
    end

    def content
      File.read(@pathname)
    end

    def deletable?
      if @basename[0] == ?_
        false
      else
        true
      end
    end
  end


  class DirectoryIndex < RenderableFile
    def save(content)
      raise IllegalPagePath.new("Cannot save, #{@pathname} is a directory")
    end

    def directories
      children.select(&:directory?).map do |path|
        RenderableFile.build(path.expand_path)
      end
    end

    def pages
      pages = children.select(&:file?).map do |path|
        RenderableFile.build(path.expand_path)
      end
      pages.delete_if { |p| p.basename[0] == ?_ }
    end

    def deletable?
      false
    end

    def directory?
      @pathname.directory?
    end

    private def children
      @pathname.children.sort
    end
  end
end
