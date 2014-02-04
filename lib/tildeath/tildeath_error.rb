module Tildeath
  class TildeathError < StandardError
    attr_reader :line_number, :column

    def initialize(line_number, column)
      super()
      @line_number = line_number
      @column = column
    end
  end
end
