module Tildeath
  module ASTNodes
    class Value
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def execute(context)
        context[@value].alive?
      end

      def to_s
        @value
      end
    end
  end
end
