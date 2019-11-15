require "../spec_helper"

describe ExcelParser::Book do
  it "return correct number of sheets" do
    book = ExcelParser::Book.new(file_io)
    book.sheets.size.should eq(2)
    book.close
  end
end
