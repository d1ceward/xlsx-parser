require "compress/zip"

# Build an in-memory xlsx file from minimal XML parts, used to test edge cases
# without committing binary fixtures.
module XlsxBuilder
  NS = %(xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" ) +
       %(xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships")

  # *sheets* maps a sheet name to its <sheetData> content (and optional extra XML after it)
  def self.build(sheets : Hash(String, String),
                 shared_strings : String? = nil,
                 styles : String? = nil,
                 states = {} of String => String,
                 absolute_targets = false,
                 workbook_pr = "") : IO::Memory
    io = IO::Memory.new

    Compress::Zip::Writer.open(io) do |zip|
      sheet_nodes = sheets.keys.map_with_index do |name, index|
        state = states[name]?.try { |value| %( state="#{value}") }
        %(<sheet name="#{name}" sheetId="#{index + 1}" r:id="rId#{index + 1}"#{state}/>)
      end

      # Relationships are written in reverse order since their order is not guaranteed
      rel_nodes = sheets.keys.map_with_index do |_, index|
        target = "#{absolute_targets ? "/xl/" : ""}worksheets/sheet#{index + 1}.xml"
        %(<Relationship Id="rId#{index + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="#{target}"/>)
      end

      zip.add("xl/workbook.xml", %(<workbook #{NS}>#{workbook_pr}<sheets>#{sheet_nodes.join}</sheets></workbook>))
      zip.add("xl/_rels/workbook.xml.rels",
        %(<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">#{rel_nodes.reverse.join}</Relationships>))
      zip.add("xl/sharedStrings.xml", %(<sst #{NS}>#{shared_strings}</sst>)) if shared_strings
      zip.add("xl/styles.xml", %(<styleSheet #{NS}>#{styles}</styleSheet>)) if styles

      sheets.values.each_with_index do |content, index|
        zip.add("xl/worksheets/sheet#{index + 1}.xml", %(<worksheet #{NS}>#{content}</worksheet>))
      end
    end

    io.rewind
    io
  end
end
