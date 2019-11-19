module XlsxParser
  class Sheet
    getter node : XML::Reader

    def initialize(@book : Book, @file : String)
      @node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
    end

    def rows
      Iterator.of do
        row = nil
        cell = nil
        cell_type = nil

        loop do
          break unless @node.read
          if @node.name == "row"
            if @node.node_type == XML::Reader::Type::ELEMENT
              row = {} of String => String | Int32
            else
              break
            end
          elsif @node.name == "c" && @node.node_type == XML::Reader::Type::ELEMENT
            cell_type = node["t"]?
            cell = node["r"]?
          elsif @node.name == "v" && @node.node_type == XML::Reader::Type::ELEMENT && row && cell
            row[cell] = convert(cell_type)
          end
        end

        row || Iterator.stop
      end
    end

    private def convert(type : String?) : String | Int32
      value = @node.read_inner_xml

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
