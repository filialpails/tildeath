require_relative '../imminently_deceased_object'

module Tildeath
  module ASTNodes
    class Bifurcate
      attr_reader :original, :parts

      def initialize(orig, parts)
        @original = orig
        @parts = parts
      end

      def execute(context)
        type = context[@original].type
        @parts.each do |part|
          context[part] = ImminentlyDeceasedObject.new(type, part)
        end
      end

      def to_s
        @parts[1..-1].reduce("bifurcate #{@original}[#{@parts[0]}") {|memo, part|
          memo << ', ' << part.to_s
        } << ']'
      end
    end
  end
end
