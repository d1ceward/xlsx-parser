require "spec"
require "../src/xlsx_parser"

def file_io : IO
  File.new(__DIR__ + "/fixtures/valid.xlsx")
end
