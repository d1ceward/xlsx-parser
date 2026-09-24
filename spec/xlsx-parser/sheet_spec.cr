require "../spec_helper"

describe XlsxParser::Sheet do
  it "return correct rows number for the first sheet" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    book.sheets[0].rows.size.should eq(4)
    book.close
  end

  it "return correct rows number for the second sheet" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    book.sheets[1].rows.size.should eq(1)
    book.close
  end

  it "return a valid row on the first sheet" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    book.sheets[0].rows.first.should eq({"A1" => "First Name", "B1" => "Last Name", "C1" => "Email",
                                         "D1" => "Address", "E1" => "Surprise", "F1" => "Phone",
                                         "G1" => "Column with int", "H1" => "Column with float",
                                         "I1" => "Column with str", "J1" => "Empty column"})
    book.close
  end

  it "return a valid row on the second sheet" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    book.sheets[1].rows.first.should eq({"A1" => "Not empty…"})
    book.close
  end

  it "parses Int64 values correctly" do
    book = XlsxParser::Book.new("./spec/fixtures/sample_int64.xlsx")
    row = book.sheets[0].rows.first
    row["A1"].should eq(133_369_153_956_i64)
    row["B1"].should eq(1_234_567_890)
    book.close
  end

  it "return parsed 1904 date successfully" do
    data = [
      {"A1" => "Table 1", "B1" => nil},
      {"A2" => nil, "B2" => nil},
      {"A3" => "Date", "B3" => Time.utc(2021, 1, 1)},
      {"A4" => "Datetime 00:00:00", "B4" => Time.utc(2021, 1, 1)},
      {"A5" => "Datetime", "B5" => Time.utc(2021, 1, 1, 23, 59, 58, nanosecond: 999997616)},
    ]

    book = XlsxParser::Book.new("./spec/fixtures/sample_dates_1904.xlsx")
    book.sheets[0].rows.each_with_index { |row, index| row.should eq(data[index]) }
    book.close
  end

  it "return parsed 1900 date successfully" do
    data = [
      {"A1" => "Table 1", "B1" => nil},
      {"A2" => nil, "B2" => nil},
      {"A3" => "Date", "B3" => Time.utc(2021, 1, 1)},
      {"A4" => "Datetime 00:00:00", "B4" => Time.utc(2021, 1, 1)},
      {"A5" => "Datetime", "B5" => Time.utc(2021, 1, 1, 23, 59, 58, nanosecond: 999997616)},
    ]

    book = XlsxParser::Book.new("./spec/fixtures/sample_dates_1900.xlsx")
    book.sheets[0].rows.each_with_index { |row, index| row.should eq(data[index]) }
    book.close
  end

  it "return correct data format with unspecified style in XML" do
    book = XlsxParser::Book.new("./spec/fixtures/sample_unspecified_style.xlsx")
    book.sheets[0].rows.first.should eq({"A1" => 42, "B1" => "string", "C1" => 2.3})
    book.close
  end

  it "handles empty sheets gracefully" do
    book = XlsxParser::Book.new("./spec/fixtures/sample_empty_sheet.xlsx")
    book.sheets[0].rows.to_a.should eq([] of Hash(String, XlsxParser::Sheet::Type))
    book.close
  end

  it "parses boolean values correctly" do
    # The sample_bool.xlsx should contain TRUE in A1 and FALSE in B1
    book = XlsxParser::Book.new("./spec/fixtures/sample_bool.xlsx")
    row = book.sheets[0].rows.first
    row["A1"].should be_true
    row["B1"].should be_false
    book.close
  end

  it "can iterate rows several times" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    sheet = book.sheets[0]
    sheet.rows.to_a.size.should eq(4)
    sheet.rows.to_a.size.should eq(4)
    book.close
  end

  describe "cell types" do
    book = XlsxParser::Book.new(XlsxBuilder.build(
      {"S1" => <<-XML
        <sheetData><row r="1">
          <c r="A1" t="inlineStr"><is><t>inline</t></is></c>
          <c r="B1" t="inlineStr"><is><r><t>rich </t></r><r><t>inline</t></r></is></c>
          <c r="C1" t="str"><f>"12"&amp;"3"</f><v>123</v></c>
          <c r="D1" t="e"><f>1/0</f><v>#DIV/0!</v></c>
          <c r="E1" t="n"><v>5</v></c>
          <c r="F1" t="n"><v>1E-3</v></c>
          <c r="G1" t="d"><v>2021-01-01T10:30:00</v></c>
          <c r="H1" t="d"><v>2021-01-01</v></c>
          <c r="I1" t="b"><v>1</v></c>
        </row></sheetData>
        XML
      }
    ))
    row = book.sheets[0].rows.first

    it { row["A1"].should eq("inline") }
    it { row["B1"].should eq("rich inline") }
    it { row["C1"].should eq("123") }
    it { row["D1"].should eq("#DIV/0!") }
    it { row["E1"].should eq(5) }
    it { row["F1"].should eq(0.001) }
    it { row["G1"].should eq(Time.utc(2021, 1, 1, 10, 30)) }
    it { row["H1"].should eq(Time.utc(2021, 1, 1)) }
    it { row["I1"].should be_true }
  end

  describe "row structure" do
    it "returns empty self-closing rows" do
      book = XlsxParser::Book.new(XlsxBuilder.build({"S1" => <<-XML
        <sheetData>
          <row r="1"><c r="A1"><v>1</v></c></row>
          <row r="2"/>
          <row r="3"><c r="B3"><v>3</v></c></row>
        </sheetData>
        XML
      }))
      book.sheets[0].rows.to_a.should eq([{"A1" => 1}, {} of String => XlsxParser::Sheet::Type?, {"A3" => nil, "B3" => 3}])
      book.close
    end

    it "handles rows and cells without reference" do
      book = XlsxParser::Book.new(XlsxBuilder.build({"S1" => <<-XML
        <sheetData>
          <row><c><v>1</v></c><c><v>2</v></c></row>
          <row><c><v>3</v></c></row>
        </sheetData>
        XML
      }))
      book.sheets[0].rows.to_a.should eq([{"A1" => 1, "B1" => 2}, {"A2" => 3}])
      book.close
    end

    it "handles columns after Z" do
      book = XlsxParser::Book.new(XlsxBuilder.build({"S1" => %(<sheetData><row r="1"><c r="AB1"><v>1</v></c></row></sheetData>)}))
      row = book.sheets[0].rows.first
      row.size.should eq(28)
      row["AB1"].should eq(1)
      book.close
    end

    it "handles namespace prefixed elements" do
      content = %(<x:worksheet xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main">) \
                %(<x:sheetData><x:row r="1"><x:c r="A1"><x:v>1</x:v></x:c></x:row></x:sheetData></x:worksheet>)
      io = IO::Memory.new
      source = XlsxBuilder.build({"S1" => "<sheetData/>"})
      Compress::Zip::Writer.open(io) do |zip|
        Compress::Zip::Reader.open(source) do |reader|
          reader.each_entry do |entry|
            zip.add(entry.filename, entry.filename.ends_with?("sheet1.xml") ? content : entry.io.gets_to_end)
          end
        end
      end
      io.rewind

      book = XlsxParser::Book.new(io)
      book.sheets[0].rows.first.should eq({"A1" => 1})
      book.close
    end
  end

  describe "#rows_with_headers" do
    it "indexes rows by the first row values" do
      book = XlsxParser::Book.new(XlsxBuilder.build({"S1" => <<-XML
        <sheetData>
          <row r="1"><c r="A1" t="inlineStr"><is><t>Name</t></is></c><c r="C1" t="inlineStr"><is><t>Age</t></is></c></row>
          <row r="2"><c r="A2" t="inlineStr"><is><t>Alice</t></is></c><c r="B2"><v>1</v></c><c r="C2"><v>30</v></c></row>
        </sheetData>
        XML
      }))
      book.sheets[0].rows_with_headers.to_a.should eq([{"Name" => "Alice", "B" => 1, "Age" => 30}])
      book.close
    end

    it "returns nothing for an empty sheet" do
      book = XlsxParser::Book.new("./spec/fixtures/sample_empty_sheet.xlsx")
      book.sheets[0].rows_with_headers.to_a.should be_empty
      book.close
    end
  end

  describe "#cell" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    sheet = book.sheets[0]

    it { sheet.cell("A1").should eq("First Name") }
    it { sheet.cell("b1").should eq("Last Name") }
    it { sheet.cell("J2").should be_nil }
    it { sheet.cell("A99").should be_nil }
    it { sheet.cell("invalid").should be_nil }
  end

  describe "#merged_cells" do
    it "returns merged ranges" do
      book = XlsxParser::Book.new(XlsxBuilder.build({"S1" => <<-XML
        <sheetData/><mergeCells count="2"><mergeCell ref="A1:B2"/><mergeCell ref="C3:D3"/></mergeCells>
        XML
      }))
      book.sheets[0].merged_cells.should eq(["A1:B2", "C3:D3"])
      book.close
    end
  end

  describe ".column_index / .column_name" do
    it { XlsxParser::Sheet.column_index("A1").should eq(1) }
    it { XlsxParser::Sheet.column_index("AB12").should eq(28) }
    it { XlsxParser::Sheet.column_name(1).should eq("A") }
    it { XlsxParser::Sheet.column_name(26).should eq("Z") }
    it { XlsxParser::Sheet.column_name(28).should eq("AB") }
    it { XlsxParser::Sheet.column_name(703).should eq("AAA") }
  end
end
