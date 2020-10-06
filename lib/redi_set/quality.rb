module RediSet
  class Quality
    attr_reader :attribute, :name

    def initialize(attribute:, name:)
      @attribute = attribute
      @name = name
    end

    def key
      @_key ||= "#{RediSet.prefix}.attr:#{attribute.name}:#{name}"
    end
  end
end
