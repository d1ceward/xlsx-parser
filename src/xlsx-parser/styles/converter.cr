module XlsxParser::Styles
  class Converter
    ISO_DATE_FORMATS = ["%FT%T.%N", "%FT%T", "%F"]

    # Convert the raw `value` of a cell given its type attribute (`t`) and style format.
    #
    # Handled cell types: s (shared string), inlineStr, str (formula string), e (error),
    # b (boolean), d (ISO 8601 date) and n (number, the default).
    def self.call(value : String, type : String?, style : Format?, book : Book) : Sheet::Type
      case type
      when "s"
        convert_shared_string(value, book)
      when "inlineStr", "str", "e"
        value
      when "b"
        value == "1" || value.downcase == "true"
      when "d"
        convert_iso_date(value)
      else
        convert_number(value, style || Format::General, book)
      end
    end

    private def self.convert_number(value : String, style : Format, book : Book) : Sheet::Type
      case style
      when .temporal?
        convert_time(value, book)
      when .integer?
        convert_int(value) || convert_float(value) || value
      when .float?, .percentage?, .scientific?
        convert_float(value) || value
      else
        convert_int(value) || convert_float(value) || value
      end
    end

    private def self.convert_shared_string(value : String, book : Book) : String
      index = value.to_i? || raise InvalidFileError.new("Invalid shared string index: #{value}")
      book.shared_strings[index]? || raise InvalidFileError.new("Missing shared string at index #{index}")
    end

    private def self.convert_int(value : String) : (Int32 | Int64)?
      value.to_i32? || value.to_i64?
    end

    private def self.convert_float(value : String) : Float64?
      value.to_f?
    end

    private def self.convert_time(value : String, book : Book) : Time | String
      days = value.to_f?
      return value unless days

      book.base_time + days.days
    end

    # Excel may omit the time zone or the time part, values are then considered as UTC
    private def self.convert_iso_date(value : String) : Time | String
      begin
        return Time.parse_iso8601(value)
      rescue Time::Format::Error
      end

      ISO_DATE_FORMATS.each do |format|
        return Time.parse_utc(value, format)
      rescue Time::Format::Error
        next
      end

      value
    end
  end
end
