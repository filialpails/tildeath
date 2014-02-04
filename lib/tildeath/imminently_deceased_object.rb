module Tildeath
  class ImminentlyDeceasedObject
    attr_reader :type, :name

    def initialize(type, name)
      @type = type
      @name = name
      @alive = true
    end

    def die
      @alive = false
    end

    def alive?
      @alive
    end
  end
end
