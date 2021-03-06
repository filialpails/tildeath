module Tildeath
  module ASTNodes
    class DotDie
      attr_reader :victim

      def initialize(victim)
        @victim = victim
      end

      def execute(context)
        return unless context[:THIS].alive?
        context[@victim].die
      end

      def to_s
        "#{@victim}.DIE()"
      end
    end
  end
end
