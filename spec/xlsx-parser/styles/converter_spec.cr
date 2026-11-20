require "../../spec_helper"

private alias C = XlsxParser::Styles::Converter
private alias F = XlsxParser::Styles::Format

describe XlsxParser::Styles::Converter do
  describe ".call" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")

    describe "convert float successfully" do
      it { C.call("1.2", "n", nil, book).should eq(1.2) }
      it { C.call("7.2", nil, F::Float, book).should eq(7.2) }
      it { C.call("5.2", nil, F::Percentage, book).should eq(5.2) }
      it { C.call("3.2", nil, F::Unsupported, book).should eq(3.2) }
      it { C.call("3.2", nil, nil, book).should eq(3.2) }
    end

    describe "convert int successfully" do
      it { C.call("42", nil, F::Integer, book).should eq(42) }
      it { C.call("1024", nil, F::Unsupported, book).should eq(1024) }
      it { C.call("2042", nil, nil, book).should eq(2042) }
    end

    describe "convert string successfully" do
      it { C.call("ipsum", nil, F::General, book).should eq("ipsum") }
      it { C.call("primis", nil, F::Unsupported, book).should eq("primis") }
      it { C.call("sapien", nil, nil, book).should eq("sapien") }
    end

    describe "convert numbers regardless of the float representation" do
      it { C.call("5", "n", nil, book).should eq(5) }
      it { C.call("5", nil, F::Float, book).should eq(5.0) }
      it { C.call("1.5E-2", nil, F::Scientific, book).should eq(0.015) }
      it { C.call("3.5", nil, F::Integer, book).should eq(3.5) }
    end

    it "raises on missing shared string" do
      expect_raises(XlsxParser::InvalidFileError, "Missing shared string at index 9999") do
        C.call("9999", "s", nil, book)
      end
    end
  end
end
