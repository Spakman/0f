require "minitest/autorun"

require_relative "../lib/renderable_file"

describe RenderableFile do
  it "cannot be instantiated directly" do
    assert_raises(NoMethodError) { RenderableFile.new("/path") }
  end

  describe "building" do
    let(:valid_path) { "path" }
    let(:path_includes_file) { "file/another" }
    let(:pathname_includes_file) { Pathname.new(File.expand_path("#{__FILE__}/../../pages/file")) }

    before do
      RenderableFile.directory_whitelist = [ "pages", "more_pages" ]
    end

    it "raises an IllegalPagePath exception when the path is not nested below directories in the whitelist" do
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

    it "allows paths nested below directories in the whitelist" do
      assert RenderableFile.build("hello")
      assert RenderableFile.build("../more_pages/hello")
    end
  end
end
