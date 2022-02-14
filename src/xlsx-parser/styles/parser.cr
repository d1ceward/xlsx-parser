module XlsxParser::Styles
  class Parser
    def self.call(book : Book) : Array(Symbol | Nil)
      return [] of Symbol? unless (styles_file = book.zip["xl/styles.xml"]?)

      styles = XML.parse(styles_file.open(&.gets_to_end))
      custom_style_types = parse_custom_style_types(styles)
      styles_nodes = styles.xpath_nodes("//*[name()='styleSheet']//*[name()='cellXfs']//*[name()='xf']")

      styles_nodes.map do |xstyle|
        next unless (num_fmt_id = xstyle.attributes["numFmtId"]?.try(&.content).try(&.to_i))

        NumFmtMap[num_fmt_id]? || custom_style_types[num_fmt_id]
      end
    end

    private def self.parse_custom_style_types(styles) : Hash(Int32, Symbol)
      custom_style_types = {} of Int32 => Symbol

      styles.xpath_nodes("//*[name()='styleSheet']//*[name()='numFmts']//*[name()='numFmt']")
            .each do |xstyle|
        index = xstyle.attributes["numFmtId"].content.to_i
        value = xstyle.attributes["formatCode"].content

        custom_style_types[index] = determine_custom_style_type(value)
      end

      custom_style_types
    end

    private def self.determine_custom_style_type(string : String) : Symbol
      return :float if string[0] == "_"
      return :float if string[0] == " 0"

      # Looks for one of ymdhis outside of meta-stuff like [Red]
      return :date_time if string =~ /(^|\])[^\[]*[ymdhis]/i

      :unsupported
    end
  end
end
