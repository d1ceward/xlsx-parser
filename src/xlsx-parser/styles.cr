require "./styles/parser"
require "./styles/converter"

# Module XlsxParser::Styles contains a map of non-custom numFmtId to casting format.
#
# The `Format` of a cell tells the converter which type should be used when parsing the cell value.
module XlsxParser::Styles
  enum Format
    # No explicit type, the value is guessed (Int32, Int64, Float64 or String)
    General
    Integer
    Float
    Percentage
    Scientific
    Date
    Time
    DateTime
    # Known format without dedicated conversion, the value is guessed like `General`
    Unsupported

    def temporal? : Bool
      date? || time? || date_time?
    end
  end

  # Built-in number formats, see ECMA-376 Part 1, 18.8.30 numFmt.
  # Ids 27-36 and 50-58 are locale dependent (CJK dates and times).
  NumFmtMap = {
     0 => Format::General,     # General
     1 => Format::Integer,     # 0
     2 => Format::Float,       # 0.00
     3 => Format::Integer,     # #,##0
     4 => Format::Float,       # #,##0.00
     5 => Format::Unsupported, # $#,##0_);($#,##0)
     6 => Format::Unsupported, # $#,##0_);[Red]($#,##0)
     7 => Format::Unsupported, # $#,##0.00_);($#,##0.00)
     8 => Format::Unsupported, # $#,##0.00_);[Red]($#,##0.00)
     9 => Format::Percentage,  # 0%
    10 => Format::Percentage,  # 0.00%
    11 => Format::Scientific,  # 0.00E+00
    12 => Format::Unsupported, # # ?/?
    13 => Format::Unsupported, # # ??/??
    14 => Format::Date,        # mm-dd-yy
    15 => Format::Date,        # d-mmm-yy
    16 => Format::Date,        # d-mmm
    17 => Format::Date,        # mmm-yy
    18 => Format::Time,        # h:mm AM/PM
    19 => Format::Time,        # h:mm:ss AM/PM
    20 => Format::Time,        # h:mm
    21 => Format::Time,        # h:mm:ss
    22 => Format::DateTime,    # m/d/yy h:mm
    27 => Format::Date,        # locale dependent
    28 => Format::Date,        # locale dependent
    29 => Format::Date,        # locale dependent
    30 => Format::Date,        # locale dependent
    31 => Format::Date,        # locale dependent
    32 => Format::Time,        # locale dependent
    33 => Format::Time,        # locale dependent
    34 => Format::Time,        # locale dependent
    35 => Format::Time,        # locale dependent
    36 => Format::Date,        # locale dependent
    37 => Format::Unsupported, # #,##0 ;(#,##0)
    38 => Format::Unsupported, # #,##0 ;[Red](#,##0)
    39 => Format::Unsupported, # #,##0.00;(#,##0.00)
    40 => Format::Unsupported, # #,##0.00;[Red](#,##0.00)
    41 => Format::Unsupported, # _(* #,##0_);_(* (#,##0);_(* "-"_);_(@_)
    42 => Format::Unsupported, # _($* #,##0_);_($* (#,##0);_($* "-"_);_(@_)
    43 => Format::Unsupported, # _(* #,##0.00_);_(* (#,##0.00);_(* "-"??_);_(@_)
    44 => Format::Unsupported, # _($* #,##0.00_);_($* (#,##0.00);_($* "-"??_);_(@_)
    45 => Format::Time,        # mm:ss
    46 => Format::Time,        # [h]:mm:ss
    47 => Format::Time,        # mmss.0
    48 => Format::Scientific,  # ##0.0E+0
    49 => Format::Unsupported, # @
    50 => Format::Date,        # locale dependent
    51 => Format::Date,        # locale dependent
    52 => Format::Date,        # locale dependent
    53 => Format::Date,        # locale dependent
    54 => Format::Date,        # locale dependent
    55 => Format::Time,        # locale dependent
    56 => Format::Time,        # locale dependent
    57 => Format::Date,        # locale dependent
    58 => Format::Date,        # locale dependent
  }
end
