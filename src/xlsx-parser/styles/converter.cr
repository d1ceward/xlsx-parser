module XlsxParser::Styles
  class Converter
    DATE_TYPES = %i[date time date_time]

    def self.call(value : String, type : String?, style : Symbol?, book : Book)
      resolved_type = resolve_type(type, style)
      convert_value(value, resolved_type, book)
    end

    private def self.resolve_type(type : String?, style : Symbol?)
      return style if type.nil? || (type == "n" && DATE_TYPES.includes?(style))

      type
    end

    private def self.convert_value(value : String, type, book : Book)
      case type
      when :string
        value
      when "s"
        convert_shared_string(value, book)
      when "n", :float, :percentage
        convert_float(value)
      when "b"
        convert_boolean(value)
      when :fixnum
        convert_int(value)
      when :time, :date, :date_time
        convert_time(value, book)
      else
        convert_unknown(value)
      end
    end

    private def self.convert_shared_string(value : String, book : Book) : String
      book.shared_strings[value.to_i]
    end

    private def self.convert_boolean(value : String) : Bool
      value.to_i == 1
    end

    private def self.convert_int(value : String) : Int32 | Int64 | String
      return value.to_i32 if value.to_i32?.to_s == value
      return value.to_i64 if value.to_i64?.to_s == value

      value
    end

    private def self.convert_float(value : String) : Float64 | String
      return value.to_f if value.to_f?.to_s == value

      value
    end

    private def self.convert_time(value : String, book : Book) : Time
      book.base_time + value.to_f.days
    end

    private def self.convert_unknown(value : String) : Int32 | Int64 | Float64 | String
      int_value = convert_int(value)
      return int_value unless int_value.is_a?(String)

      float_value = convert_float(value)
      return float_value unless float_value.is_a?(String)

      value
    end
  end
end
