module XlsxParser::Styles
  class Converter
    def self.call(value : String, type : String?, style : Symbol?, book : Book)
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
  end
end
