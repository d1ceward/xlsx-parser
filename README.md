# xlsx-parser

Crystal wrapper for parsing .xlsx spreadsheets

:warning: Warning : This shard is still in development, this may have lots of bugs !

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     xlsx-parser:
       github: D1ceWard/xlsx-parser
       version: 0.1.0
   ```

2. Run `shards install`

## Usage

```crystal
require "xlsx-parser"

file_io = File.new("./my_super_spreadsheet.xlsx")
book = ExcelParser::Book.new(file_io)

book.sheets[0].rows.each do |row|
  # Print row content
  puts row
end

book.close
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/D1ceWard/xlsx-parse. By contributing you agree to abide by the Code of Merit.

1. Fork it (<https://github.com/D1ceWard/xlsx-parser/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [D1ceWard](https://github.com/D1ceWard) - creator and maintainer
