module ExcelParser
  class Sheet
    def initialize(@book : Book, @file : String)
    end

    def rows
      # node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
      # rows = node.xpath_nodes("//*[name()='row']")

      # return Iterator.of do
      #   row = rows.next
      #   if rows.is_a?(Iterator::Stop)
      #     Iterator.stop
      #   else
      #     rows.xpath_nodes("//*[name()='v']").map do |v_node|
      #       @book.shared_strings[v_node.content.to_i]
      #     end
      #   end
      # end
    end
  end
end
