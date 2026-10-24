module XlsxParser::Styles
  class Parser
    # Return the `Format` of each cell style (cellXfs), indexed by style id
    def self.call(book : Book) : Array(Format)
      return [] of Format unless styles_file = book.zip["xl/styles.xml"]?

      begin
        styles = XML.parse(styles_file.open(&.gets_to_end))
      rescue XML::Error
        # If XML is invalid or cannot be parsed, return empty
        return [] of Format
      end

      custom_style_types = parse_custom_style_types(styles)

      cell_xfs_node = styles.xpath_nodes("//*[local-name()='styleSheet']//*[local-name()='cellXfs']").first?
      return [] of Format unless cell_xfs_node

      cell_xfs_node.xpath_nodes("*[local-name()='xf']").map do |xstyle|
        # numFmtId defaults to 0 (General) when omitted
        num_fmt_id = xstyle["numFmtId"]?.try(&.to_i?) || 0

        NumFmtMap[num_fmt_id]? || custom_style_types[num_fmt_id]? || Format::Unsupported
      end
    end

    private def self.parse_custom_style_types(styles) : Hash(Int32, Format)
      custom_style_types = {} of Int32 => Format

      numfmts_node = styles.xpath_nodes("//*[local-name()='styleSheet']//*[local-name()='numFmts']").first?
      return custom_style_types unless numfmts_node

      numfmts_node.xpath_nodes("*[local-name()='numFmt']").each do |xstyle|
        index = xstyle["numFmtId"]?.try(&.to_i?)
        format_code = xstyle["formatCode"]?
        next unless index && format_code

        custom_style_types[index] = determine_custom_style_type(format_code)
      end

      custom_style_types
    end

    # :nodoc:
    def self.determine_custom_style_type(format_code : String) : Format
      # Remove quoted literals ("days"), escaped chars (\d) and meta-stuff like [Red] or [$-409]
      # but keep elapsed time markers like [h] or [mm]
      code = format_code
        .gsub(/"[^"]*"/, "")
        .gsub(/\\./, "")
        .gsub(/\[(?![hms]+\])[^\]]*\]/i, "")
        .gsub(/[\[\]]/, "")

      return Format::Unsupported if code.empty?
      return Format::DateTime if code =~ /[ymdhs]/i
      return Format::Percentage if code.includes?('%')
      return Format::Float if code.starts_with?('0') || code.starts_with?('_')

      Format::Unsupported
    end
  end
end
