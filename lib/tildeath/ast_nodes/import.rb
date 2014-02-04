require_relative '../imminently_deceased_object'

module Tildeath
  module ASTNodes
    class Import
      def initialize(type, name)
        @type = type
        @name = name
      end

      def execute(context)
        return unless context[:THIS].alive?
        # Create new object of the specified type and name and store it in context
        context[@name] = ImminentlyDeceasedObject.new(@type, @name)
      end

      def to_s
        "import #{@type} #{@name}"
      end
    end
  end
end
