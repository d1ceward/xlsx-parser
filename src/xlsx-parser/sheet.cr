module XlsxParser
  # Represents a sheet in an Excel workbook.
  #
  # The `Sheet` class provides methods to read data in a sheet.
  class Sheet
    # The possible types of cell values.
    alias Type = Bool | Float64 | Int32 | Int64 | String | Time

    # A row, indexed by cell reference ("A1") or by header when using `#rows_with_headers`.
    alias Row = Hash(String, Type?)

    # The name of the sheet.
    getter name : String

    # The visibility state of the sheet: "visible", "hidden" or "veryHidden".
    getter state : String

    # Initializes a new instance of the `Sheet` class, *path* is the sheet XML path inside the zip.
    def initialize(@book : Book, @path : String, @name : String, @state : String = "visible")
    end

    # Returns true if the sheet is hidden or very hidden.
    def hidden? : Bool
      @state != "visible"
    end

    # Returns an iterator that yields a hash per row, including the cell ids and values.
    #
    # Missing cells are padded with nil from column A up to the last cell of the row.
    # Each call reads the sheet from the start.
    def rows : Iterator(Row)
      RowIterator.new(@book, reader)
    end

    # Returns an iterator that yields a hash per row indexed by the first row values.
    #
    # Columns without header are indexed by their column letter.
    def rows_with_headers : Iterator(Row)
      iterator = rows
      header_row = iterator.next
      return ([] of Row).each if header_row.is_a?(Iterator::Stop)

      headers = {} of Int32 => String
      header_row.each { |ref, value| headers[Sheet.column_index(ref)] = value.to_s unless value.nil? }

      iterator.map do |row|
        row.each_with_object(Row.new) do |(ref, value), hash|
          column = Sheet.column_index(ref)
          hash[headers[column]? || Sheet.column_name(column)] = value
        end
      end
    end

    # Returns the value of the cell with given reference ("B3"), nil if empty or missing.
    def cell(ref : String) : Type?
      ref = ref.upcase
      row_number = ref.lstrip("ABCDEFGHIJKLMNOPQRSTUVWXYZ").to_i?
      return unless row_number

      rows.each do |row|
        first_ref = row.first_key?
        next unless first_ref

        current_row_number = first_ref.lstrip("ABCDEFGHIJKLMNOPQRSTUVWXYZ").to_i
        return row[ref]? if current_row_number == row_number
        break if current_row_number > row_number
      end
    end

    # Returns the merged cell ranges of the sheet (e.g. ["A1:B2"]).
    def merged_cells : Array(String)
      xml = reader
      ranges = [] of String

      while xml.read
        next unless xml.node_type.element? && Sheet.local_name(xml.name) == "mergeCell"

        xml["ref"]?.try { |range| ranges << range }
      end

      ranges
    end

    # Returns the 1-based column index of given cell reference ("AB12" => 28).
    def self.column_index(ref : String) : Int32
      index = 0

      ref.each_char do |char|
        break unless char.ascii_letter?

        index = index * 26 + (char.upcase.ord - 'A'.ord + 1)
      end

      index
    end

    # Returns the column name of given 1-based column index (28 => "AB").
    def self.column_name(index : Int32) : String
      name = ""

      while index > 0
        index, remainder = (index - 1).divmod(26)
        name = ('A' + remainder).to_s + name
      end

      name
    end

    # :nodoc:
    # Remove namespace prefix of given element name ("x:row" => "row")
    def self.local_name(name : String) : String
      name.split(':').last
    end

    private def reader : XML::Reader
      entry = @book.zip[@path]? || raise InvalidFileError.new("Missing #{@path}")

      XML::Reader.new(entry.open(&.gets_to_end))
    end

    private class RowIterator
      include Iterator(Row)

      @row_number = 0

      def initialize(@book : Book, @reader : XML::Reader)
      end

      def next
        while @reader.read
          return read_row if element?("row")
        end

        stop
      end

      private def read_row : Row
        @row_number = @reader["r"]?.try(&.to_i?) || @row_number + 1
        values = {} of Int32 => Type
        last_column = 0

        unless @reader.empty_element?
          column = 0

          while @reader.read
            break if @reader.node_type.end_element? && Sheet.local_name(@reader.name) == "row"
            next unless element?("c")

            ref_column = @reader["r"]?.try { |ref| Sheet.column_index(ref) } || 0
            column = ref_column > 0 ? ref_column : column + 1
            last_column = column if column > last_column

            type = @reader["t"]?
            style_index = @reader["s"]?.try(&.to_i?)
            value = read_cell_value
            values[column] = convert(value, type, style_index) if value
          end
        end

        (1..last_column).each_with_object(Row.new) do |index, row|
          row["#{Sheet.column_name(index)}#{@row_number}"] = values[index]?
        end
      end

      # Return the raw value of the current cell: <v> content or inline string (<is>)
      private def read_cell_value : String?
        return if @reader.empty_element?

        @reader.expand.children.each do |child|
          case Sheet.local_name(child.name)
          when "v"  then return child.content
          when "is" then return Book.text_content(child)
          end
        end

        nil
      end

      private def element?(name : String) : Bool
        @reader.node_type.element? && Sheet.local_name(@reader.name) == name
      end

      private def convert(value : String, type : String?, style_index : Int32?) : Type
        style = style_index.try { |index| @book.style_types[index]? }

        Styles::Converter.call(value, type, style, @book)
      end
    end
  end
end
