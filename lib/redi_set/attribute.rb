module RediSet
  class Attribute
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end
end
