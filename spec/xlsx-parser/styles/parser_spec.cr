require "../../spec_helper"

describe XlsxParser::Styles::Parser do
  describe ".call" do
    it "parses style types from a real xlsx file" do
      book = XlsxParser::Book.new("spec/fixtures/sample.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([:unsupported, :unsupported, :unsupported, :unsupported, :unsupported, :unsupported])
    end

    it "returns an array with correct types for sample_int64.xlsx" do
      book = XlsxParser::Book.new("spec/fixtures/sample_int64.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([:string, :fixnum])
    end

    it "returns an array for a file with only booleans" do
      book = XlsxParser::Book.new("spec/fixtures/sample_bool.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([:string])
    end

    it "returns an array for a file with only dates (1900)" do
      book = XlsxParser::Book.new("spec/fixtures/sample_dates_1900.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([:unsupported, :unsupported, :unsupported, :unsupported, :unsupported, :date_time,
                        :date_time, :date_time])
    end

    it "returns an array for a file with only dates (1904)" do
      book = XlsxParser::Book.new("spec/fixtures/sample_dates_1904.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([:unsupported, :unsupported, :unsupported, :unsupported, :unsupported, :date_time,
                        :date_time, :date_time])
    end

    it "returns an array for a file with unspecified styles" do
      book = XlsxParser::Book.new("spec/fixtures/sample_unspecified_style.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([:unsupported, :unsupported])
    end

    it "returns an array for an empty sheet" do
      book = XlsxParser::Book.new("spec/fixtures/sample_empty_sheet.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([:string])
    end
  end
end
