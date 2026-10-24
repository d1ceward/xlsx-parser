module XlsxParser
  # Base class for every error raised by this library.
  class Error < Exception
  end

  # Raised when the given file is not a valid xlsx file.
  class InvalidFileError < Error
  end
end
