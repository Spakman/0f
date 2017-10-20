require "minitest/autorun"

require_relative "../lib/renderable_file"

describe RenderableFile do
  it "cannot be instantiated directly" do
    assert_raises(NoMethodError) { RenderableFile.new("path") }
    assert_raises(NoMethodError) { RenderableFile::Page.new("path") }
    assert_raises(NoMethodError) { RenderableFile::DirectoryIndex.new("path") }
  end

  describe "building" do
    let(:valid_path) { "path" }
    let(:path_includes_file) { "file/another" }
    let(:pathname_includes_file) { Pathname.new(File.expand_path("#{__FILE__}/../../pages/file")) }

    it "raises an IllegalPagePath exception when the path is not nested below the pages directory" do
      assert_raises(IllegalPagePath) { RenderableFile.build("../hello") }
      assert_raises(IllegalPagePath) { RenderableFile.build("/etc/passwd") }
    end

    it "raises an IllegalPagePath exception when the path contains a file ancestor instead of a directory" do
      is_file = Minitest::Mock.new.expect(:call, true, [ pathname_includes_file ])
      File.stub(:file?, is_file) do
        assert_raises(IllegalPagePath) { RenderableFile.build(path_includes_file) }
      end
    end

    it "returns a Page instance when path is a file" do
      File.stub(:directory?, ->(p) { false }) do
        assert_kind_of RenderableFile::Page, RenderableFile.build(valid_path)
      end
    end

    it "returns a DirectoryIndex instance when path is a directory" do
      File.stub(:directory?, ->(p) { true }) do
        assert_kind_of RenderableFile::DirectoryIndex, RenderableFile.build(valid_path)
      end
    end

    it "allows paths nested below the pages directory" do
      assert RenderableFile.build("hello")
      assert RenderableFile.build("../pages/hello")
    end

    it "sets the uri_path instance variable" do
      assert_equal "/hello", RenderableFile.build("hello").uri_path
      assert_equal "/", RenderableFile.build("hello/there/../../").uri_path
    end
  end
end
