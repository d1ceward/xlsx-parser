module XlsxParser
  class Sheet
    def initialize(@book : Book, @file : String)
    end

    def rows
      node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
      status = true

      Iterator.of do
        row = nil
        cell = nil
        cell_type = nil

        loop do
          break unless (status = node.read)
          if node.name == "row" && node.node_type == XML::Reader::Type::ELEMENT
            row = {} of String => String | Int32
          elsif node.name == "row" && node.node_type == XML::Reader::Type::END_ELEMENT
            break
          elsif node.name == "c" && node.node_type == XML::Reader::Type::ELEMENT
            cell_type = node["t"]
            cell = node["r"]
          elsif node.name == "v" && node.node_type == XML::Reader::Type::ELEMENT
            row[cell] = convert(node.read_inner_xml, cell_type) unless row.nil? || cell.nil?
          end
        end

        if status
          row
        else
          Iterator.stop
        end
      end
    end

    private def convert(value : String, type : String?) : String | Int32
      case type
      when "s"
        @book.shared_strings[value.to_i]
      when "n"
        value.to_i
      else
        value
      end
    end
  end
end
