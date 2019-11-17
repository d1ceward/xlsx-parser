module ExcelParser
  class Sheet
    def initialize(@book : Book, @file : String)
    end

    def rows
      node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
    end
  end
end
