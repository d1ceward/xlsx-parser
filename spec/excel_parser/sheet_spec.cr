require "../spec_helper"

describe ExcelParser::Sheet do
  book = ExcelParser::Book.new(file_io)

  it "return correct rows number" do
    book.sheets[0].rows.size.should eq(3)
    book.sheets[1].rows.size.should eq(1)
  end

  book.close
end
