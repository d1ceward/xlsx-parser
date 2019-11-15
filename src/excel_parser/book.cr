require "zip"
require "xml"

module ExcelParser
  class Book
    getter zip : Zip::File
    getter sheets : Array(Sheet) = [] of Sheet

    def initialize(io : IO)
      @zip = Zip::File.new(io)
    end

    def sheets
      @sheets = sheet_rel_nodes.map do |relation|
        Sheet.new(self, relation["Target"])
      end
    end

    # Parse XML node of each relationships corresponding to sheets
    private def sheet_rel_nodes : XML::NodeSet
      # Open/parse relationships document
      xml = XML.parse(@zip["xl/_rels/workbook.xml.rels"].open(&.gets_to_end))

      # Get relationships children as node set
      xml.xpath_nodes("//*[name()='Relationship' and contains(@Target,'sheet')]")
    end

    def close
      @zip.close
    end
  end
end
