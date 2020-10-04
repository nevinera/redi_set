require "securerandom"

module RediSet
  class Constraint
    def initialize(attribute:, values:)
      @attribute = attribute
      @values = values
    end

    attr_reader :attribute, :values

    def requires_union?
      values.length > 1
    end

    def union_key
      @_key ||= "rs.union:#{SecureRandom.uuid}"
    end

    def set_keys
      values.map { |v| "rs.attr:#{attribute}:#{v}" }
    end

    def intersection_key
      if set_keys.empty?
        nil
      elsif requires_union?
        union_key
      else
        set_keys.first
      end
    end
  end
end
