# xlsx-parser (v1.3.0)
![GitHub Workflow Status (event)](https://github.com/d1ceward/xlsx-parser/actions/workflows/main.yml/badge.svg?branch=master)
[![GitHub issues](https://img.shields.io/github/issues/d1ceward/xlsx-parser)](https://github.com/d1ceward/xlsx-parser/issues)
[![GitHub license](https://img.shields.io/github/license/d1ceward/xlsx-parser)](https://github.com/d1ceward/xlsx-parser/blob/master/LICENSE)

Crystal wrapper for parsing .xlsx spreadsheets

:rocket: Suggestions for new improvements are welcome in the issue tracker.

Note: Work with Cystal versions `>= 0.36.0, < 2.0.0`

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     xlsx-parser:
       github: d1ceward/xlsx-parser
       version: 1.3.0
   ```

2. Run `shards install`

## Usage

### With IO
```crystal
require "xlsx-parser"

file_io = File.new("./my_super_spreadsheet.xlsx")
book = XlsxParser::Book.new(file_io)
```

### With file path
```crystal
require "xlsx-parser"

book = XlsxParser::Book.new("./my_super_spreadsheet.xlsx")
```

### Print rows content
```crystal
# Iterate on each row of the first sheet
book.sheets[0].rows.each do |row|
  puts row #=> { "A1" => "Col A Row 1", "B1" => "Col B Row 1" }
end

# Second sheet
book.sheets[1]

book.close
```

Documentation available here : https://d1ceward.github.io/xlsx-parser/

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/d1ceward/xlsx-parser. By contributing you agree to abide by the Code of Merit.

1. Fork it (<https://github.com/d1ceward/xlsx-parser/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [d1ceward](https://github.com/d1ceward) - creator and maintainer
