require "../../spec_helper"

describe XlsxParser::Styles::Converter do
  describe ".call" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")

    describe "convert float successfully" do
      it { XlsxParser::Styles::Converter.call("1.2", "n", nil, book).should eq(1.2) }
      it { XlsxParser::Styles::Converter.call("7.2", nil, XlsxParser::Styles::Format::Float, book).should eq(7.2) }
      it { XlsxParser::Styles::Converter.call("5.2", nil, XlsxParser::Styles::Format::Percentage, book).should eq(5.2) }
      it { XlsxParser::Styles::Converter.call("3.2", nil, XlsxParser::Styles::Format::Unsupported, book).should eq(3.2) }
      it { XlsxParser::Styles::Converter.call("3.2", nil, nil, book).should eq(3.2) }
    end

    describe "convert int successfully" do
      it { XlsxParser::Styles::Converter.call("42", nil, XlsxParser::Styles::Format::Integer, book).should eq(42) }
      it { XlsxParser::Styles::Converter.call("1024", nil, XlsxParser::Styles::Format::Unsupported, book).should eq(1024) }
      it { XlsxParser::Styles::Converter.call("2042", nil, nil, book).should eq(2042) }
    end

    describe "convert string successfully" do
      it { XlsxParser::Styles::Converter.call("ipsum", nil, XlsxParser::Styles::Format::General, book).should eq("ipsum") }
      it { XlsxParser::Styles::Converter.call("primis", nil, XlsxParser::Styles::Format::Unsupported, book).should eq("primis") }
      it { XlsxParser::Styles::Converter.call("sapien", nil, nil, book).should eq("sapien") }
    end

    describe "convert numbers regardless of the float representation" do
      it { XlsxParser::Styles::Converter.call("5", "n", nil, book).should eq(5) }
      it { XlsxParser::Styles::Converter.call("5", nil, XlsxParser::Styles::Format::Float, book).should eq(5.0) }
      it { XlsxParser::Styles::Converter.call("1.5E-2", nil, XlsxParser::Styles::Format::Scientific, book).should eq(0.015) }
      it { XlsxParser::Styles::Converter.call("3.5", nil, XlsxParser::Styles::Format::Integer, book).should eq(3.5) }
    end

    it "raises on missing shared string" do
      expect_raises(XlsxParser::InvalidFileError, "Missing shared string at index 9999") do
        XlsxParser::Styles::Converter.call("9999", "s", nil, book)
      end
    end
  end
end
