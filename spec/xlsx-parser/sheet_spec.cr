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
                                          "G1" => "Column with int", "H1" => "Empty column" })
    book.close
  end

  it "return a valid row on the second sheet" do
    book = XlsxParser::Book.new("./spec/fixtures/sample.xlsx")
    book.sheets[1].rows.first.should eq({"A1" => "Not empty…"})
    book.close
  end

  it "return parsed date successfully" do
    book = XlsxParser::Book.new("./spec/fixtures/sample_dates.xlsx")
    book.sheets[0].rows.each do |row|
      p row
    end
    book.close
  end
end
