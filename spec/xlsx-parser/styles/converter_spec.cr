require "../../spec_helper"

describe XlsxParser::Styles::Converter do
  describe ".call" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")

    describe "convert float successfully" do
      it { XlsxParser::Styles::Converter.call("1.2", "n", nil, book).should eq(1.2) }
      it { XlsxParser::Styles::Converter.call("7.2", nil, :float, book).should eq(7.2) }
      it { XlsxParser::Styles::Converter.call("5.2", nil, :percentage, book).should eq(5.2) }
      it { XlsxParser::Styles::Converter.call("3.2", nil, :unsupported, book).should eq(3.2) }
      it { XlsxParser::Styles::Converter.call("3.2", nil, nil, book).should eq(3.2) }
    end

    describe "convert int successfully" do
      it { XlsxParser::Styles::Converter.call("42", nil, :fixnum, book).should eq(42) }
      it { XlsxParser::Styles::Converter.call("1024", nil, :unsupported, book).should eq(1024) }
      it { XlsxParser::Styles::Converter.call("2042", nil, nil, book).should eq(2042) }
    end

    describe "convert string successfully" do
      it { XlsxParser::Styles::Converter.call("ipsum", nil, :string, book).should eq("ipsum") }
      it { XlsxParser::Styles::Converter.call("primis", nil, :unsupported, book).should eq("primis") }
      it { XlsxParser::Styles::Converter.call("sapien", nil, nil, book).should eq("sapien") }
    end
  end
end
