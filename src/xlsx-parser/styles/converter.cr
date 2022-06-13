module XlsxParser::Styles
  class Converter
    DATE_TYPES = %i[date time date_time]

    # ameba:disable Metrics/CyclomaticComplexity
    def self.call(value : String, type : String?, style : Symbol?, book : Book)
      # Sometimes the type is dictated by the style alone
      if type.nil? || (type == "n" && DATE_TYPES.includes?(style))
        type = style
      end

      case type
      when "s"
        book.shared_strings[value.to_i]
      when "n"
        value.to_f
      when 'b'
        value.to_i == 1
      when :string
        value
      when :unsupported
        convert_unknown(value)
      when :fixnum
        value.to_i
      when :float, :percentage
        value.to_f
      when :time, :date, :date_time
        convert_time(value, book)
      else
        convert_unknown(value)
      end
    end

    private def self.convert_unknown(value : String)
      if value.try(&.to_i).to_s == value
        value.to_i
      elsif value.try(&.to_i).to_s == value
        value.to_f
      else
        value
      end
    end

    private def self.convert_time(value : String, book : Book) : Time
      book.base_time + value.to_f.days
    end
  end
end
