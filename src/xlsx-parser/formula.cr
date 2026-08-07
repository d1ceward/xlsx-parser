require "compress/zip"
require "xml"

module XlsxParser
  # Extracts formulas from Excel worksheet XML files.
  #
  # Excel stores formulas in `<f>` elements within `<c>` (cell) elements.
  # Format: `<c r="A1"><f>SUM(B1:B10)</f><v>550</v></c>`
  #
  # ### Example
  #
  # ```
  # book = XlsxParser::Book.new("./my_super_spreadsheet.xlsx")
  #
  # # Extract formulas from first sheet
  # formulas = XlsxParser::Formula.extract(book, 0)
  # # => {"A1" => "SUM(B1:B10)", "C5" => "AVERAGE(A1:A10)"}
  #
  # # Extract formulas from specific sheet
  # formulas = XlsxParser::Formula.extract_file("./my_super_spreadsheet.xlsx", 0)
  #
  # book.close
  # ```
  class Formula
    # Extracts formulas from a specific worksheet in an xlsx file.
    #
    # Parameters:
    # - `filename`: Path to the .xlsx file
    # - `sheet_index`: Zero-based index of the sheet (0 = first sheet)
    #
    # Returns a hash mapping cell references to formula strings.
    def self.extract_file(filename : String, sheet_index : Int32) : Hash(String, String)
      formulas = {} of String => String

      begin
        Compress::Zip::File.open(filename) do |zip|
          # Resolve actual worksheet path from workbook relationships
          sheet_path = resolve_sheet_path(zip, sheet_index)

          if sheet_path && zip[sheet_path]?
            xml_content = zip[sheet_path].open(&.gets_to_end)
            formulas = parse_formulas_from_xml(xml_content)
          end
        end
      rescue ex : Exception
        # If we can't extract formulas, return empty hash
        # This allows the importer to still work with values
        formulas = {} of String => String
      end

      formulas
    end

    # Extracts formulas from a Book object for a specific sheet.
    #
    # Parameters:
    # - `book`: XlsxParser::Book object
    # - `sheet_index`: Zero-based index of the sheet (0 = first sheet)
    #
    # Returns a hash mapping cell references to formula strings.
    def self.extract(book : Book, sheet_index : Int32) : Hash(String, String)
      begin
        # Resolve actual worksheet path from workbook relationships
        sheet_path = resolve_sheet_path(book.zip, sheet_index)

        if sheet_path && book.zip[sheet_path]?
          xml_content = book.zip[sheet_path].open(&.gets_to_end)
          return parse_formulas_from_xml(xml_content)
        end
      rescue ex : Exception
        # Return empty hash on any error
      end

      {} of String => String
    end

    # Extracts formulas from all sheets in a workbook.
    #
    # Parameters:
    # - `filename`: Path to the .xlsx file
    # - `sheet_count`: Number of sheets to extract formulas from
    #
    # Returns an array of hashes, one per sheet.
    def self.extract_all_sheets(filename : String, sheet_count : Int32) : Array(Hash(String, String))
      all_formulas = Array(Hash(String, String)).new

      sheet_count.times do |i|
        formulas = extract_file(filename, i)
        all_formulas << formulas
      end

      all_formulas
    end

    # Resolves the actual worksheet XML path from workbook relationships.
    # This is necessary because worksheet files may not be named sheet1.xml, sheet2.xml, etc.
    private def self.resolve_sheet_path(zip : Compress::Zip::File, sheet_index : Int32) : String?
      begin
        # Parse workbook.xml to get sheet IDs
        workbook = XML.parse(zip["xl/workbook.xml"].open(&.gets_to_end))
        sheets_nodes = workbook.xpath_nodes("//*[name()='sheet']")

        return nil if sheet_index >= sheets_nodes.size

        sheet_node = sheets_nodes[sheet_index]
        sheet_id = sheet_node["id"]?

        return nil unless sheet_id

        # Parse workbook relationships to find the actual worksheet file
        rels = XML.parse(zip["xl/_rels/workbook.xml.rels"].open(&.gets_to_end))
        sheet_file = rels.xpath_string(
          "string(//*[name()='Relationship' and contains(@Id,'#{sheet_id}')]/@Target)"
        )

        # Target is relative to xl/ directory
        sheet_file.empty? ? nil : "xl/#{sheet_file}"
      rescue ex : Exception
        nil
      end
    end

    # Parses formulas from worksheet XML content.
    #
    # Parameters:
    # - `xml_content`: The XML content from a worksheet file
    #
    # Returns a hash mapping cell references to formula strings.
    private def self.parse_formulas_from_xml(xml_content : String) : Hash(String, String)
      formulas = {} of String => String

      begin
        doc = XML.parse(xml_content)

        # Find all <c> (cell) elements using local-name() to handle namespaces
        # Then check for <f> (formula) children
        doc.xpath_nodes("//*[local-name()='c']").each do |cell_node|
          # Get cell reference from r attribute (e.g., "A1")
          cell_ref = cell_node["r"]?

          if cell_ref
            # Look for <f> (formula) element as a child
            formula_nodes = cell_node.xpath_nodes("./*[local-name()='f']")

            if formula_nodes.size > 0
              formula_node = formula_nodes.first

              # Check if this is a shared formula
              formula_type = formula_node["type"]?
              shared_index = formula_node["ref"]? || formula_node["si"]?

              # Get formula content
              formula = if formula_type == "shared" && shared_index && formula_node.content.empty?
                          # For shared formulas without content, we could resolve the master
                          # For now, store a placeholder to indicate shared formula
                          "SHARED_FORMULA(#{shared_index})"
                        else
                          formula_node.content.strip
                        end

              # Only store non-empty formulas (or shared formula placeholders)
              unless formula.empty?
                formulas[cell_ref] = formula
              end
            end
          end
        end
      rescue ex : Exception
        # If XML parsing fails, return empty hash
        formulas = {} of String => String
      end

      formulas
    end
  end
end
