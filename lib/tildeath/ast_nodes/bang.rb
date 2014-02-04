module Tildeath
  module ASTNodes
    class Bang
      def initialize(value)
        @value = value
      end

      def execute(context)
        !@value.execute(context)
      end

      def to_s
        "!#{@value}"
      end
    end
  end
end
