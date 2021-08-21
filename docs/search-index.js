crystal_doc_search_index_callback({"repository_name":"xlsx-parser","body":"# xlsx-parser (v0.8.2)\n\nCrystal wrapper for parsing .xlsx spreadsheets\n\n:rocket: Suggestions for new improvements are welcome in the issue tracker.\n\nNote: Work with Cystal versions `>= 0.36.1, < 2.0.0`\n\n## Installation\n\n1. Add the dependency to your `shard.yml`:\n\n   ```yaml\n   dependencies:\n     xlsx-parser:\n       github: D1ceWard/xlsx-parser\n       version: 0.8.2\n   ```\n\n2. Run `shards install`\n\n## Usage\n\n### With IO\n```crystal\nrequire \"xlsx-parser\"\n\nfile_io = File.new(\"./my_super_spreadsheet.xlsx\")\nbook = XlsxParser::Book.new(file_io)\n```\n\n### With file path\n```crystal\nrequire \"xlsx-parser\"\n\nbook = XlsxParser::Book.new(\"./my_super_spreadsheet.xlsx\")\n```\n\n### Print rows content\n```crystal\n# Iterate on each row of the first sheet\nbook.sheets[0].rows.each do |row|\n  puts row #=> { \"A1\" => \"Col A Row 1\", \"B1\" => \"Col B Row 1\" }\nend\n\n# Second sheet\nbook.sheets[1]\n\nbook.close\n```\n\n## Contributing\n\nBug reports and pull requests are welcome on GitHub at https://github.com/D1ceWard/xlsx-parser. By contributing you agree to abide by the Code of Merit.\n\n1. Fork it (<https://github.com/D1ceWard/xlsx-parser/fork>)\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## Contributors\n\n- [D1ceWard](https://github.com/D1ceWard) - creator and maintainer\n","program":{"html_id":"xlsx-parser/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"superclass":null,"ancestors":[],"locations":[],"repository_name":"xlsx-parser","program":true,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[],"instance_methods":[],"macros":[],"types":[{"html_id":"xlsx-parser/XlsxParser","path":"XlsxParser.html","kind":"module","full_name":"XlsxParser","name":"XlsxParser","abstract":false,"superclass":null,"ancestors":[],"locations":[],"repository_name":"xlsx-parser","program":false,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[{"id":"VERSION","name":"VERSION","value":"\"0.8.2\"","doc":null,"summary":null}],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[],"instance_methods":[],"macros":[],"types":[{"html_id":"xlsx-parser/XlsxParser/Book","path":"XlsxParser/Book.html","kind":"class","full_name":"XlsxParser::Book","name":"Book","abstract":false,"superclass":{"html_id":"xlsx-parser/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"xlsx-parser/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"xlsx-parser/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[],"repository_name":"xlsx-parser","program":false,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":{"html_id":"xlsx-parser/XlsxParser","kind":"module","full_name":"XlsxParser","name":"XlsxParser"},"doc":null,"summary":null,"class_methods":[],"constructors":[{"id":"new(file:IO|String,check_file_extension=true)-class-method","html_id":"new(file:IO|String,check_file_extension=true)-class-method","name":"new","doc":null,"summary":null,"abstract":false,"args":[{"name":"file","doc":null,"default_value":"","external_name":"file","restriction":"IO | String"},{"name":"check_file_extension","doc":null,"default_value":"true","external_name":"check_file_extension","restriction":""}],"args_string":"(file : IO | String, check_file_extension = <span class=\"n\">true</span>)","args_html":"(file : IO | String, check_file_extension = <span class=\"n\">true</span>)","location":{"filename":"src/xlsx-parser/book.cr","line_number":10,"url":null},"def":{"name":"new","args":[{"name":"file","doc":null,"default_value":"","external_name":"file","restriction":"IO | String"},{"name":"check_file_extension","doc":null,"default_value":"true","external_name":"check_file_extension","restriction":""}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"_ = allocate\n_.initialize(file, check_file_extension)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"id":"close-instance-method","html_id":"close-instance-method","name":"close","doc":null,"summary":null,"abstract":false,"args":[],"args_string":"","args_html":"","location":{"filename":"src/xlsx-parser/book.cr","line_number":45,"url":null},"def":{"name":"close","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"@zip.close"}},{"id":"shared_strings:Array(String)-instance-method","html_id":"shared_strings:Array(String)-instance-method","name":"shared_strings","doc":null,"summary":null,"abstract":false,"args":[],"args_string":" : Array(String)","args_html":" : Array(String)","location":{"filename":"src/xlsx-parser/book.cr","line_number":8,"url":null},"def":{"name":"shared_strings","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"Array(String)","visibility":"Public","body":"@shared_strings"}},{"id":"sheets-instance-method","html_id":"sheets-instance-method","name":"sheets","doc":null,"summary":null,"abstract":false,"args":[],"args_string":"","args_html":"","location":{"filename":"src/xlsx-parser/book.cr","line_number":31,"url":null},"def":{"name":"sheets","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"workbook = XML.parse(@zip[\"xl/workbook.xml\"].open(&.gets_to_end))\nsheets_nodes = workbook.xpath_nodes(\"//*[name()='sheet']\")\nrels = XML.parse(@zip[\"xl/_rels/workbook.xml.rels\"].open(&.gets_to_end))\n@sheets = sheets_nodes.map do |sheet|\n  sheetfile = rels.xpath_string(\"string(//*[name()='Relationship' and contains(@Id,'#{sheet[\"id\"]}')]/@Target)\")\n  Sheet.new(self, sheetfile)\nend\n"}},{"id":"zip:Compress::Zip::File-instance-method","html_id":"zip:Compress::Zip::File-instance-method","name":"zip","doc":null,"summary":null,"abstract":false,"args":[],"args_string":" : Compress::Zip::File","args_html":" : Compress::Zip::File","location":{"filename":"src/xlsx-parser/book.cr","line_number":6,"url":null},"def":{"name":"zip","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"Compress::Zip::File","visibility":"Public","body":"@zip"}}],"macros":[],"types":[]},{"html_id":"xlsx-parser/XlsxParser/Sheet","path":"XlsxParser/Sheet.html","kind":"class","full_name":"XlsxParser::Sheet","name":"Sheet","abstract":false,"superclass":{"html_id":"xlsx-parser/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"xlsx-parser/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"xlsx-parser/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[],"repository_name":"xlsx-parser","program":false,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":{"html_id":"xlsx-parser/XlsxParser","kind":"module","full_name":"XlsxParser","name":"XlsxParser"},"doc":null,"summary":null,"class_methods":[],"constructors":[{"id":"new(book:Book,file:String)-class-method","html_id":"new(book:Book,file:String)-class-method","name":"new","doc":null,"summary":null,"abstract":false,"args":[{"name":"book","doc":null,"default_value":"","external_name":"book","restriction":"Book"},{"name":"file","doc":null,"default_value":"","external_name":"file","restriction":"String"}],"args_string":"(book : Book, file : String)","args_html":"(book : <a href=\"../XlsxParser/Book.html\">Book</a>, file : String)","location":{"filename":"src/xlsx-parser/sheet.cr","line_number":5,"url":null},"def":{"name":"new","args":[{"name":"book","doc":null,"default_value":"","external_name":"book","restriction":"Book"},{"name":"file","doc":null,"default_value":"","external_name":"file","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"_ = allocate\n_.initialize(book, file)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"id":"node:XML::Reader-instance-method","html_id":"node:XML::Reader-instance-method","name":"node","doc":null,"summary":null,"abstract":false,"args":[],"args_string":" : XML::Reader","args_html":" : XML::Reader","location":{"filename":"src/xlsx-parser/sheet.cr","line_number":3,"url":null},"def":{"name":"node","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"XML::Reader","visibility":"Public","body":"@node"}},{"id":"rows-instance-method","html_id":"rows-instance-method","name":"rows","doc":null,"summary":null,"abstract":false,"args":[],"args_string":"","args_html":"","location":{"filename":"src/xlsx-parser/sheet.cr","line_number":9,"url":null},"def":{"name":"rows","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"Iterator.of do\n  row = nil\n  row_index = nil\n  cell = nil\n  cell_type = nil\n  loop do\n    if @node.read\n    else\n      break\n    end\n    if @node.name == \"row\"\n      if @node.node_type == XML::Reader::Type::ELEMENT\n        row = {} of String => String | Int32\n        row_index = node[\"r\"]?\n      else\n        row = inner_padding(row, row_index, cell)\n        break\n      end\n    else\n      if (@node.name == \"c\") && (@node.node_type == XML::Reader::Type::ELEMENT)\n        cell_type = node[\"t\"]?\n        cell = node[\"r\"]?\n      else\n        if (((@node.name == \"v\") && (@node.node_type == XML::Reader::Type::ELEMENT)) && row) && cell\n          row[cell] = convert(cell_type)\n        end\n      end\n    end\n  end\n  row || Iterator.stop\nend"}}],"macros":[],"types":[]}]}]}})