module RediSet
  class Constraint
    def initialize(attribute:, values:)
      @attribute = attribute
      @values = values
    end

    attr_reader :attribute, :values

    def set_keys
      values.map { |v| "rs.attr:#{attribute}:#{v}" }
    end
  end
end
