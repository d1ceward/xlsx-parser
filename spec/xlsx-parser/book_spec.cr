require "../spec_helper"

describe XlsxParser::Book do
  describe "#new" do
    it "open an xlsx file successfully" do
      book = XlsxParser::Book.new(dir_helper("/fixtures/sample.xlsx"))
      book.should be_truthy
      book.close
    end

    it "fail to open a legacy xls file" do
      expect_raises(ArgumentError, "Not a valid file format") do
        XlsxParser::Book.new(dir_helper("/fixtures/invalid.xls"))
      end
    end

    it "ignore file extensions on request" do
      path = dir_helper("/fixtures/sample.zip")
      book = XlsxParser::Book.new(path, check_file_extension: false)
      book.close
    end

    it "check file extensions on request" do
      path = dir_helper("/fixtures/sample.zip")
      expect_raises(ArgumentError, "Not a valid file format") do
        XlsxParser::Book.new(path, check_file_extension: true)
      end
    end
  end
end
