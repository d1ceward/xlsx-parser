require "../spec_helper"

describe ExcelParser::Sheet do
  book = ExcelParser::Book.new(file_io)

  it "return correct rows number for first sheet" do
    book.sheets[0].rows
  end

  book.close
end
