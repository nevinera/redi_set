require "securerandom"

module RediSet
  class Constraint
    UNION_EXPIRATION_PERIOD = 60 # seconds

    def initialize(attribute:, values:)
      @attribute = attribute
      @values = values
    end

    attr_reader :attribute, :values

    def requires_union?
      values.length > 1
    end

    def intersection_key
      if values.empty?
        nil
      elsif requires_union?
        union_key
      else
        set_keys.first
      end
    end

    def store_union(redis)
      redis.sunionstore union_key, *set_keys
      redis.expire(union_key, UNION_EXPIRATION_PERIOD)
    end

    private

    def set_keys
      @_set_keys ||= values.map { |v| "#{RediSet.prefix}.attr:#{attribute}:#{v}" }
    end

    def union_key
      @_key ||= "#{RediSet.prefix}.union:#{SecureRandom.uuid}"
    end
  end
end
