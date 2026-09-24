require "../../spec_helper"

private alias F = XlsxParser::Styles::Format

describe XlsxParser::Styles::Parser do
  describe ".call" do
    it "parses style types from a real xlsx file" do
      book = XlsxParser::Book.new("spec/fixtures/sample.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([F::Unsupported, F::Unsupported, F::Unsupported, F::Unsupported, F::Unsupported, F::Unsupported])
    end

    it "returns an array with correct types for sample_int64.xlsx" do
      book = XlsxParser::Book.new("spec/fixtures/sample_int64.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([F::General, F::Integer])
    end

    it "returns an array for a file with only booleans" do
      book = XlsxParser::Book.new("spec/fixtures/sample_bool.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([F::General])
    end

    it "returns an array for a file with only dates (1900)" do
      book = XlsxParser::Book.new("spec/fixtures/sample_dates_1900.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([F::Unsupported, F::Unsupported, F::Unsupported, F::Unsupported, F::Unsupported, F::DateTime,
                        F::DateTime, F::DateTime])
    end

    it "returns an array for a file with only dates (1904)" do
      book = XlsxParser::Book.new("spec/fixtures/sample_dates_1904.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([F::Unsupported, F::Unsupported, F::Unsupported, F::Unsupported, F::Unsupported, F::DateTime,
                        F::DateTime, F::DateTime])
    end

    it "returns an array for a file with unspecified styles" do
      book = XlsxParser::Book.new("spec/fixtures/sample_unspecified_style.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([F::Unsupported, F::Unsupported])
    end

    it "returns an array for an empty sheet" do
      book = XlsxParser::Book.new("spec/fixtures/sample_empty_sheet.xlsx")
      result = XlsxParser::Styles::Parser.call(book)
      result.should eq([F::General])
    end
  end

  it "does not crash on built-in formats missing from the map or empty format codes" do
    styles = %(<numFmts count="1"><numFmt numFmtId="200" formatCode=""/></numFmts>) \
             %(<cellXfs count="4"><xf numFmtId="44"/><xf numFmtId="200"/><xf numFmtId="999"/><xf/></cellXfs>)
    book = XlsxParser::Book.new(XlsxBuilder.build({"S1" => "<sheetData/>"}, styles: styles))
    XlsxParser::Styles::Parser.call(book).should eq([F::Unsupported, F::Unsupported, F::Unsupported, F::General])
    book.close
  end

  describe ".determine_custom_style_type" do
    {
      "yyyy-mm-dd"      => F::DateTime,
      "[h]:mm:ss"       => F::DateTime,
      "[$-409]d-mmm-yy" => F::DateTime,
      "[Red]0.00"       => F::Float,
      "0.00"            => F::Float,
      "0.0%"            => F::Percentage,
      %(#,##0 "days")   => F::Unsupported,
      %(0\\h)           => F::Float,
      "@"               => F::Unsupported,
      ""                => F::Unsupported,
    }.each do |format_code, expected|
      it "detects #{format_code.inspect} as #{expected}" do
        XlsxParser::Styles::Parser.determine_custom_style_type(format_code).should eq(expected)
      end
    end
  end
end
