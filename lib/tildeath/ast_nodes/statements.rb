module Tildeath
  module ASTNodes
    class Statements
      def initialize(statements=[])
        @statements = statements
      end

      def execute(context)
        return unless context[:THIS].alive?
        @statements.each do |statement|
          return unless context[:THIS].alive?
          statement.execute(context)
        end
      end

      def to_s
        @statements.reduce('') do |memo, stmt|
          memo << stmt.to_s << ";\n"
        end
      end
    end
  end
end
