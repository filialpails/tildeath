module Tildeath
  module ASTNodes
    class Null
      def execute(context); end

      def to_s
        'NULL'
      end
    end
  end
end
