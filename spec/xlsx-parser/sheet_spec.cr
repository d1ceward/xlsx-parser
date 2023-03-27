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
    book.sheets[0].rows.first.should eq({ "A1" => "First Name", "B1" => "Last Name", "C1" => "Email",
                                          "D1" => "Address", "E1" => "Surprise", "F1" => "Phone",
                                          "G1" => "Column with int", "H1" => "Column with float",
                                          "I1" => "Column with str", "J1" => "Empty column" })
    book.close
  end

  it "return a valid row on the second sheet" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    book.sheets[1].rows.first.should eq({"A1" => "Not empty…"})
    book.close
  end

  it "return parsed 1904 date successfully" do
    data = [
      { "A1" => "Table 1", "B1" => nil },
      { "A2" => nil, "B2" => nil },
      { "A3" => "Date", "B3" => Time.utc(2021, 1, 1) },
      { "A4" => "Datetime 00:00:00", "B4" => Time.utc(2021, 1, 1) },
      { "A5" => "Datetime", "B5" =>  Time.utc(2021, 1, 1, 23, 59, 58, nanosecond: 999997616) }
    ]

    book = XlsxParser::Book.new("./spec/fixtures/sample_dates_1904.xlsx")
    book.sheets[0].rows.each_with_index { |row, index| row.should eq(data[index]) }
    book.close
  end

  it "return parsed 1900 date successfully" do
    data = [
      { "A1" => "Table 1", "B1" => nil },
      { "A2" => nil, "B2" => nil },
      { "A3" => "Date", "B3" => Time.utc(2021, 1, 1) },
      { "A4" => "Datetime 00:00:00", "B4" => Time.utc(2021, 1, 1) },
      { "A5" => "Datetime", "B5" =>  Time.utc(2021, 1, 1, 23, 59, 58, nanosecond: 999997616) }
    ]

    book = XlsxParser::Book.new("./spec/fixtures/sample_dates_1900.xlsx")
    book.sheets[0].rows.each_with_index { |row, index| row.should eq(data[index]) }
    book.close
  end

  it "return correct data format with unspecified style in XML" do
    book = XlsxParser::Book.new("./spec/fixtures/sample_unspecified_style.xlsx")
    book.sheets[0].rows.first.should eq({ "A1" => 42, "B1" => "string", "C1" => 2.3 })
    book.close
  end
end
