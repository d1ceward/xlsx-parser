require "zip"
require "xml"

module ExcelParser
  class Book
    getter zip : Zip::File
    getter sheets : Array(Sheet) = [] of Sheet
    getter shared_strings : Hash(Int32, String)

    def initialize(io : IO)
      @zip = Zip::File.new(io)
      @shared_strings = {} of Int32 => String

      node = XML.parse(@zip["xl/sharedStrings.xml"].open(&.gets_to_end))
      node.xpath_nodes("//*[name()='si']/*[name()='t']").each_with_index do |t_node, index|
        @shared_strings[index] = t_node.content
      end
    end

    def sheets
      node = XML.parse(@zip["xl/_rels/workbook.xml.rels"].open(&.gets_to_end))
      nodes = node.xpath_nodes("//*[name()='Relationship' and contains(@Target,'sheet')]")
      @sheets = nodes.map do |relation|
        Sheet.new(self, relation["Target"])
      end
    end

    def close
      @zip.close
    end
  end
end
