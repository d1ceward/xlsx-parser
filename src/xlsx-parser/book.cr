require "compress/zip"
require "xml"

module XlsxParser
  class Book
    getter zip : Compress::Zip::File
    getter shared_strings : Array(String)
    getter base_time : Time

    TIME_1900 = Time.utc(1899, 12, 30)
    TIME_1904 = Time.utc(1904, 1, 1)

    @workbook : XML::Node
    @sheets : Array(Sheet)?
    @style_types : Array(Styles::Format)?

    # Open given file/filename, yield the book and close it afterwards
    def self.open(file : IO | String, check_file_extension = true, & : Book -> T) : T forall T
      book = new(file, check_file_extension)

      begin
        yield book
      ensure
        book.close
      end
    end

    # Open given file/filename and store shared strings data
    def initialize(file : IO | String, check_file_extension = true) : Nil
      if file.is_a?(String) && check_file_extension
        extname = File.extname(file).downcase
        raise InvalidFileError.new("Not a valid file format") if extname != ".xlsx"
      end

      zip = begin
        Compress::Zip::File.new(file)
      rescue Compress::Zip::Error
        raise InvalidFileError.new("Not a valid file format")
      end

      @zip = zip
      @workbook, @shared_strings, @base_time = Book.close_on_error(zip) do
        workbook = Book.parse_xml(zip, "xl/workbook.xml")
        {workbook, Book.parse_shared_strings(zip), Book.parse_base_time(workbook)}
      end
    end

    # Return a array of sheets
    def sheets : Array(Sheet)
      @sheets ||= begin
        targets = {} of String => String
        rels = Book.parse_xml(@zip, "xl/_rels/workbook.xml.rels")
        rels.xpath_nodes("//*[local-name()='Relationship']").each do |rel|
          id, target = rel["Id"]?, rel["Target"]?
          targets[id] = target if id && target
        end

        @workbook.xpath_nodes("//*[local-name()='sheets']/*[local-name()='sheet']").map do |sheet|
          target = sheet["id"]?.try { |id| targets[id]? }
          raise InvalidFileError.new("Missing relationship for sheet #{sheet["name"]?}") unless target

          Sheet.new(self, sheet_path(target), sheet["name"]? || "", sheet["state"]? || "visible")
        end
      end
    end

    # Return true if sheet with given name exists otherwise return false
    def sheet_exists?(name : String) : Bool
      sheets.any? { |sheet| sheet.name == name }
    end

    # Return sheet with given name
    def sheet(name : String) : Sheet?
      sheets.find { |sheet| sheet.name == name }
    end

    # Close previously opened given file/filename
    def close : Nil
      @zip.close
    end

    def style_types : Array(Styles::Format)
      @style_types ||= Styles::Parser.call(self)
    end

    # Close given zip when the block raises
    protected def self.close_on_error(zip : Compress::Zip::File, &)
      yield
    rescue ex
      zip.close
      raise ex
    end

    # Return the parsed XML of given zip entry
    protected def self.parse_xml(zip : Compress::Zip::File, path : String) : XML::Node
      entry = zip[path]? || raise InvalidFileError.new("Missing #{path}")
      XML.parse(entry.open(&.gets_to_end))
    end

    # Relationship targets are relative to xl/ unless absolute
    private def sheet_path(target : String) : String
      return target.lchop('/') if target.starts_with?('/')

      Path.posix("xl").join(target).normalize.to_s
    end

    # Rich text strings are split in several runs (<r><t>...</t></r>), phonetic runs (<rPh>) are ignored
    protected def self.parse_shared_strings(zip : Compress::Zip::File) : Array(String)
      return [] of String unless zip["xl/sharedStrings.xml"]?

      shared_strings = parse_xml(zip, "xl/sharedStrings.xml")
      shared_strings.xpath_nodes("//*[local-name()='sst']/*[local-name()='si']").map do |node|
        Book.text_content(node)
      end
    end

    # :nodoc:
    # Concatenate text of <t> children and <r><t> runs of given node (<si> or <is>)
    def self.text_content(node : XML::Node) : String
      String.build do |io|
        node.children.each do |child|
          case Sheet.local_name(child.name)
          when "t"
            io << child.content
          when "r"
            child.children.each do |run_child|
              io << run_child.content if Sheet.local_name(run_child.name) == "t"
            end
          end
        end
      end
    end

    # Return base time given from workbookPr
    # http://msdn.microsoft.com/en-us/library/ff530155(v=office.12).aspx
    protected def self.parse_base_time(workbook : XML::Node) : Time
      date1904 = workbook.xpath_nodes("//*[local-name()='workbookPr']").any? do |workbook_pr|
        workbook_pr["date1904"]? =~ /\A(true|1)\z/i
      end

      date1904 ? TIME_1904 : TIME_1900
    end
  end
end
