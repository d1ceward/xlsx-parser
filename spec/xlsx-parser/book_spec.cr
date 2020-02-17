require "../spec_helper"

describe XlsxParser::Book do
  describe "#new" do
    it "open an xlsx file successfully" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.should be_truthy
      book.close
    end

    it "fail to open a legacy xls file" do
      expect_raises(ArgumentError, "Not a valid file format") do
        XlsxParser::Book.new("./spec/fixtures/invalid.xls")
      end
    end

    it "ignore file extensions on request" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.zip", check_file_extension: false)
      book.close
    end

    it "check file extensions on request" do
      expect_raises(ArgumentError, "Not a valid file format") do
        XlsxParser::Book.new("./spec/fixtures/sample.zip", check_file_extension: true)
      end
    end
  end

  describe "#sheets" do
    it "return an array of Sheet class instance" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.sheets.should be_a(Array(XlsxParser::Sheet))
      book.close
    end

    it "return correct number of sheets" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.sheets.size.should eq(2)
      book.close
    end
  end
end
