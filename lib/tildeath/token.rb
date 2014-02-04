module Tildeath
  class Token
    attr_reader :name, :value, :line_number, :column

    def initialize(name, line_number, column, value = nil)
      @name = name
      @value = value #only used by IDENT tokens, to store the actual identifier
      @line_number = line_number
      @column = column
    end
  end
end
