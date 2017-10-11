require "minitest/autorun"

require_relative "../lib/page"

describe Page do
  describe "instantiating" do
    before do
      Page.directory_whitelist = [ "pages", "more_pages" ]
    end

    it "allows paths nested below directories in the whitelist" do
      assert Page.new("hello")
      assert Page.new("../more_pages/hello")
    end

    it "raises an IllegalPagePath exception if the path is not nested below directories in the whitelist" do
      assert_raises(IllegalPagePath) { Page.new("../hello") }
    end
  end
end
