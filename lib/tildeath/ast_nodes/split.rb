require_relative '../imminently_deceased_object'

module Tildeath
  module ASTNodes
    class Split
      def initialize(orig, parts)
        @orig = orig
        @parts = parts
      end

      def execute(context)
        type = context[@orig].type
        @parts.each do |part|
          context[part] = ImminentlyDeceasedObject.new(type, part)
        end
      end

      def to_s
        @parts[1..-1].reduce("split #{@orig}[#{@parts[0]}") {|memo, part|
          memo << ', ' << part.to_s
        } << ']'
      end
    end
  end
end
