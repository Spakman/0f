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

    it "sets the basename instance variable" do
      assert_equal "hello", RenderableFile.build("hello").basename
      assert_equal "there", RenderableFile.build("hello/over/there").basename
      assert_equal "/", RenderableFile.build("hello/there/../../").basename
    end

    describe "a directory pathname" do
      let(:directory_path) { "private" }

      it "returns a Page instance for the _ page if with_index_page is true" do
        File.stub(:directory?, ->(p) { true }) do
          assert_kind_of RenderableFile::Page, RenderableFile.build(directory_path, with_index_page: true)
        end
      end

      it "returns a DirectoryIndex instance for path if with_index_page is false" do
        File.stub(:directory?, ->(p) { true }) do
          assert_kind_of RenderableFile::DirectoryIndex, RenderableFile.build(directory_path, with_index_page: false)
        end
      end
    end

    describe "#movable?" do
      it "returns false if the current page is /" do
        refute RenderableFile.build("_").movable?
      end

      it "returns false if the current page is /private" do
        refute RenderableFile.build("private").movable?
      end

      it "returns false if the current page does not yet exist" do
        refute RenderableFile.build("this-is-a-new-page").movable?
      end
    end

    describe "moving to a new path" do
      let(:old_filename) { "old_test_file" }
      let(:new_filename) { "new_test_target" }
      let(:existing_filename) { "existing_test_file" }
      let(:new_dirname) { "new_test_dir" }
      let(:old_full_path) { "#{RenderableFile::PAGES_ROOT}/#{old_filename}" }
      let(:new_same_dir_full_path) { "#{RenderableFile::PAGES_ROOT}/#{new_filename}" }
      let(:new_diff_dir_full_path) { "#{RenderableFile::PAGES_ROOT}/#{new_dirname}" }

      it "moves the file to the new location in the same directory" do
        FileUtils.touch(old_full_path)
        assert RenderableFile.build(old_filename).move_to(new_filename)
      ensure
        FileUtils.rm(old_full_path, force: true)
        FileUtils.rm(new_same_dir_full_path, force: true)
      end

      it "moves the file to the new location in a new directory" do
        FileUtils.touch(old_full_path)
        assert RenderableFile.build(old_filename).move_to("#{new_dirname}/#{new_filename}")
      ensure
        FileUtils.rm(old_full_path, force: true)
        FileUtils.rm_r(new_diff_dir_full_path, force: true)
      end

      it "raises an IllegalPagePath exception when trying to move /private" do
        assert_raises(IllegalPagePath) { RenderableFile.build("private").move_to("anything") }
      end

      it "raises an IllegalPagePath exception when trying to move a page to a path that already exists" do
        FileUtils.touch(old_full_path)
        FileUtils.touch(existing_filename)
        assert_raises(IllegalPagePath) { RenderableFile.build("old_filename").move_to("existing_filename") }
      ensure
        FileUtils.rm(old_full_path, force: true)
        FileUtils.rm(existing_filename, force: true)
      end
    end
  end
end
