module Tildeath
  module ASTNodes
    class Tildeath
      def initialize(victim, tildeath_body, execute_body)
        @victim = victim
        @tildeath_body = tildeath_body
        @execute_body = execute_body
      end

      def execute(context)
        fail "error: no such object: #{@victim}" unless context[@victim]
        # loop over first set of statements while victim is alive
        while context[@victim].alive?
          return unless context[:THIS].alive?
          @tildeath_body.execute(context)
        end
        # run second set of statements when victim dies
        return unless context[:THIS].alive?
        @execute_body.execute(context)
      end

      def to_s
        "~ATH(#{@victim}) {
  #{@tildeath_body}
} EXECUTE(#{@execute_body})"
      end
    end
  end
end
