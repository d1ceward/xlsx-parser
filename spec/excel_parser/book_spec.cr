require "../spec_helper"

describe XlsxParser::Book do
  it "return correct number of sheets" do
    book = XlsxParser::Book.new(file_io)
    book.sheets.size.should eq(2)
    book.close
  end
end
