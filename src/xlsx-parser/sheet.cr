module XlsxParser
  class Sheet
    getter node : XML::Reader
    getter name : String

    # All possible output types
    alias Type = Bool | Float64 | Int32 | String | Time

    def initialize(@book : Book, @file : String, @name : String)
      @node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
    end

    # Return a iterator which return an hash per row that includes the cell ids and values
    def rows
      Iterator.of do
        row = nil
        row_index = nil
        cell = nil
        cell_type = nil
        cell_style_idx = nil

        loop do
          break unless @node.read
          if @node.name == "row"
            if @node.node_type == XML::Reader::Type::ELEMENT
              row = {} of String => Type
              row_index = node["r"]?
            else
              row = inner_padding(row, row_index, cell)
              break
            end
          elsif @node.name == "c" && @node.node_type == XML::Reader::Type::ELEMENT
            cell_type = node["t"]?
            cell_style_idx = node["s"]?.try(&.to_i)
            cell = node["r"]?
          elsif @node.name == "v" && @node.node_type == XML::Reader::Type::ELEMENT && row && cell
            row[cell] = convert(@node.read_inner_xml, cell_type, cell_style_idx)
          end
        end

        row || Iterator.stop
      end
    end

    # Empty cells are being padded in using this function
    private def inner_padding(row : Hash(String, Type)?, row_index : String?, cell : String?)
      new_row = {} of String => Type | Nil
      return new_row unless row && row_index && cell

      cell_begin = "A"
      cell_end = cell.gsub(row_index, "")

      while (cell_begin <= cell_end) || (cell_begin.size < cell_end.size)
        cursor = "#{cell_begin}#{row_index}"
        new_row[cursor] = row[cursor]?
        cell_begin = cell_begin.succ
      end

      new_row
    end

    private def convert(value : String, type : String?, cell_style_idx : Int32?)
      style = cell_style_idx ? @book.style_types[cell_style_idx] : nil

      Styles::Converter.call(value, type, style, @book)
    end
  end
end
