module ExcelParser
  class Sheet
    def initialize(@book : Book, @file : String)
    end

    def rows
      node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
    end
  end
end

# class Pouet
#   property pouet : Array(Int32)

#   def initialize(@pouet = pouet)
#   end

#   def test
#     _pouet = @pouet.each

#     return Iterator.of do
#       _pouet.next
#     end
#   end
# end

# pouet = Pouet.new([1, 2, 3, 4])

# pouter = pouet.test

# puts pouter.first(4).flatten
