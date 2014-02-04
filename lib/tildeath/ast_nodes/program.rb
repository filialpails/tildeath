require_relative '../imminently_deceased_object'

module Tildeath
  module ASTNodes
    class Program
      def initialize(statements)
        @statements = statements
      end

      def execute
        context = {
          THIS: ImminentlyDeceasedObject.new(:program, :THIS)
        }
        @statements.execute(context)
      end

      def to_s
        @statements.to_s
      end
    end
  end
end
