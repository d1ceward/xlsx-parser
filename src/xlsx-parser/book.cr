require "compress/zip"
require "xml"

module XlsxParser
  class Book
    getter zip : Compress::Zip::File
    getter sheets : Array(Sheet) = [] of Sheet
    getter shared_strings : Array(String)
    getter style_types : Array(Symbol | Nil)?
    getter base_time : Time?

    TIME_1900 = Time.utc(1899, 12, 30)
    TIME_1904 = Time.utc(1904, 1, 1)

    # Open given file/filename and store shared strings data
    def initialize(file : IO | String, check_file_extension = true)
      if file.is_a?(String) && check_file_extension
        extname = File.extname(file).downcase
        raise ArgumentError.new("Not a valid file format") if extname != ".xlsx"
      end

      begin
        zip_file = Compress::Zip::File.new(file)
      rescue Compress::Zip::Error
        raise ArgumentError.new("Not a valid file format")
      end

      @zip = zip_file
      @shared_strings = [] of String

      if @zip["xl/sharedStrings.xml"]?
        node = XML.parse(@zip["xl/sharedStrings.xml"].open(&.gets_to_end))
        node.xpath_nodes("//*[name()='si']/*[name()='t']").each do |t_node|
          @shared_strings << t_node.content
        end
      end
    end

    # Return a array of sheets
    def sheets
      workbook = XML.parse(@zip["xl/workbook.xml"].open(&.gets_to_end))
      sheets_nodes = workbook.xpath_nodes("//*[name()='sheet']")

      rels = XML.parse(@zip["xl/_rels/workbook.xml.rels"].open(&.gets_to_end))

      @sheets = sheets_nodes.map do |sheet|
        sheet_file = rels.xpath_string(
          "string(//*[name()='Relationship' and contains(@Id,'#{sheet["id"]}')]/@Target)"
        )

        Sheet.new(self, sheet_file, sheet["name"])
      end
    end

    # Return true if sheet with given name exists otherwise return false
    def sheet_exists?(name : String)
      sheets.any? { |sheet| sheet.name == name }
    end

    # Return sheet with given name
    def sheet(name : String) : Sheet?
      sheets.find { |sheet| sheet.name == name }
    end

    # Close previously opened given file/filename
    def close
      @zip.close
    end

    def style_types
      @style_types ||= Styles::Parser.call(self)
    end

    # Return and store base time given from workbookPr
    # http://msdn.microsoft.com/en-us/library/ff530155(v=office.12).aspx
    def base_time
      @base_time ||= begin
        result = TIME_1900

        workbook = XML.parse(@zip["xl/workbook.xml"].open(&.gets_to_end))
        workbook.xpath_nodes("//*[name()='workbookPr']").each do |workbook_pr|
          next unless workbook_pr.try(&.attributes["date1904"]?).try(&.content) =~ /true|1/i

          result = TIME_1904
          break
        end

        result
      end
    end
  end
end
