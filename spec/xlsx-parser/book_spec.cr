require "../spec_helper"

describe XlsxParser::Book do
  describe "#new" do
    it "open an xlsx file successfully" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.should be_truthy
      book.close
    end

    it "fail to open a legacy xls file" do
      expect_raises(XlsxParser::InvalidFileError, "Not a valid file format") do
        XlsxParser::Book.new("./spec/fixtures/invalid.xls")
      end
    end

    it "ignore file extensions on request" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.zip", check_file_extension: false)
      book.close
    end

    it "check file extensions on request" do
      expect_raises(XlsxParser::InvalidFileError, "Not a valid file format") do
        XlsxParser::Book.new("./spec/fixtures/sample.zip", check_file_extension: true)
      end
    end

    it "open an xlsx from io successfully" do
      file_io = File.new("./spec/fixtures/sample.xlsx")
      book = XlsxParser::Book.new(file_io)
      book.close
    end

    it "fail to open a legacy xls from io" do
      file_io = File.new("./spec/fixtures/invalid.xls")

      expect_raises(XlsxParser::InvalidFileError, "Not a valid file format") do
        XlsxParser::Book.new(file_io)
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

  describe "#sheet_exists?" do
    it "returns true if sheet with given name exists" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.sheet_exists?("Sheet1").should be_truthy
      book.close
    end

    it "returns false if sheet with given name does not exist" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.sheet_exists?("NonexistentSheet").should be_falsey
      book.close
    end
  end

  describe "#sheet" do
    it "returns sheet with given name" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      sheet = book.sheet("Sheet1")
      sheet.should be_a(XlsxParser::Sheet)
      sheet.try(&.name).should eq("Sheet1")
      book.close
    end

    it "returns nil if sheet with given name does not exist" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      sheet = book.sheet("NonexistentSheet")
      sheet.should be_nil
      book.close
    end
  end

  describe "#close" do
    it "closes the previously opened file" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.close
      book.zip.closed?.should be_truthy
    end
  end

  describe "#style_types" do
    it "return an array of Sheet class instance" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.style_types
      book.close
    end
  end

  describe "#base_time" do
    it "returns the base time from workbookPr" do
      book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
      book.base_time.should eq(Time.utc(1899, 12, 30))
      book.close
    end
  end

  describe ".open" do
    it "yields the book and closes it afterwards" do
      zip = nil
      XlsxParser::Book.open("./spec/fixtures/sample.xlsx") do |book|
        book.sheets.size.should eq(2)
        zip = book.zip
      end
      zip.try(&.closed?).should be_true
    end

    it "closes the book when the block raises" do
      zip = nil
      expect_raises(Exception, "boom") do
        XlsxParser::Book.open("./spec/fixtures/sample.xlsx") do |book|
          zip = book.zip
          raise "boom"
        end
      end
      zip.try(&.closed?).should be_true
    end
  end

  describe "errors" do
    it "raises an InvalidFileError which is a XlsxParser::Error" do
      expect_raises(XlsxParser::Error, "Not a valid file format") do
        XlsxParser::Book.new("./spec/fixtures/invalid.xls")
      end
    end

    it "raises an InvalidFileError when workbook.xml is missing" do
      io = IO::Memory.new
      Compress::Zip::Writer.open(io, &.add("foo.txt", "bar"))
      io.rewind

      expect_raises(XlsxParser::InvalidFileError, "Missing xl/workbook.xml") do
        XlsxParser::Book.new(io)
      end
    end
  end

  describe "sheets resolution" do
    it "memoizes sheets" do
      XlsxParser::Book.open("./spec/fixtures/sample.xlsx") do |book|
        book.sheets[0].should be(book.sheets[0])
      end
    end

    it "maps each sheet to its own relationship when there are 10+ sheets" do
      sheets = (1..11).to_h { |index| {"S#{index}", %(<sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>#{index}</t></is></c></row></sheetData>)} }
      book = XlsxParser::Book.new(XlsxBuilder.build(sheets))

      book.sheets.map { |sheet| sheet.rows.first["A1"] }.should eq((1..11).map(&.to_s))
      book.close
    end

    it "supports absolute relationship targets" do
      io = XlsxBuilder.build({"S1" => %(<sheetData><row r="1"><c r="A1"><v>1</v></c></row></sheetData>)},
        absolute_targets: true)
      book = XlsxParser::Book.new(io)
      book.sheets[0].rows.first.should eq({"A1" => 1})
      book.close
    end

    it "exposes the sheet visibility" do
      io = XlsxBuilder.build({"S1" => "<sheetData/>", "S2" => "<sheetData/>"}, states: {"S2" => "hidden"})
      book = XlsxParser::Book.new(io)
      book.sheets.map(&.hidden?).should eq([false, true])
      book.sheets[1].state.should eq("hidden")
      book.close
    end
  end

  describe "#shared_strings" do
    it "concatenates rich text runs and ignores phonetic runs" do
      shared_strings = "<si><t>plain</t></si>" \
                       "<si><r><rPr><b/></rPr><t>Rich </t></r><r><t>text</t></r><rPh><t>ignored</t></rPh></si>" \
                       "<si><t>after</t></si>"
      book = XlsxParser::Book.new(XlsxBuilder.build({"S1" => "<sheetData/>"}, shared_strings: shared_strings))
      book.shared_strings.should eq(["plain", "Rich text", "after"])
      book.close
    end
  end
end
