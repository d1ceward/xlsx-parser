module ExcelParser
  class Sheet
    def initialize(@book : Book, @file : String)
    end

    def rows
      node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
      status = true

      return Iterator.of do
        Iterator.stop
        row = nil
        cell = nil

        loop do
          break unless (status = node.read)
          if node.name == "row" && node.node_type == XML::Reader::Type::ELEMENT
            row = {} of String => String
          elsif node.name == "row" && node.node_type == XML::Reader::Type::END_ELEMENT
            break
          elsif node.name == "c" && node.node_type == XML::Reader::Type::ELEMENT
            cell = node["r"]
          elsif node.name == "v" && node.node_type == XML::Reader::Type::ELEMENT
            row.not_nil![cell.not_nil!] = @book.shared_strings[node.read_inner_xml.to_i]
          end
        end

        if status
          row
        else
          Iterator.stop
        end
      end
    end
  end
end
