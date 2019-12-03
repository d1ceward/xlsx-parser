require "../spec_helper"

describe XlsxParser::Sheet do
  it "return correct rows number" do
    book = XlsxParser::Book.new(dir_helper("/fixtures/sample.xlsx"))
    book.sheets[0].rows.each do |t|
      puts t
    end
    book.sheets[0].rows.size.should eq(3)
    book.sheets[1].rows.size.should eq(1)
    book.close
  end
end
