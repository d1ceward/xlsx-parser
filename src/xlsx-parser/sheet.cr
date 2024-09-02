module XlsxParser
  # Represents a sheet in an Excel workbook.
  #
  # The `Sheet` class provides methods to read and manipulate data in a sheet.
  class Sheet
    # The XML reader for the sheet.
    getter node : XML::Reader

    # The name of the sheet.
    getter name : String

    # The possible types of cell values.
    alias Type = Bool | Float64 | Int32 | String | Time

    # Initializes a new instance of the `Sheet` class.
    def initialize(@book : Book, @file : String, @name : String)
      @node = XML::Reader.new(@book.zip["xl/#{@file}"].open(&.gets_to_end))
    end

    # Returns an iterator that yields a hash per row, including the cell ids and values.
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

    # This private method is used to pad empty cells in a row.
    # It returns a new row hash with padded empty cells.
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

    # Converts the given value to the specified type using the provided cell style index.
    private def convert(value : String, type : String?, cell_style_idx : Int32?)
      style = cell_style_idx ? @book.style_types[cell_style_idx] : nil

      Styles::Converter.call(value, type, style, @book)
    end
  end
end
