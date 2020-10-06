require "securerandom"

module RediSet
  class Constraint
    UNION_EXPIRATION_PERIOD = 60 # seconds

    def initialize(qualities:)
      @qualities = qualities

      if qualities.length < 1
        raise ArgumentError, "A constraint must have at least one quality"
      elsif qualities.map(&:attribute).uniq.length != 1
        raise ArgumentError, "All qualities in a constraint must have matching attributes"
      end
    end

    attr_reader :qualities

    def attribute
      qualities.first.attribute
    end

    def requires_union?
      qualities.length > 1
    end

    def intersection_key
      if requires_union?
        union_key
      else
        qualities.first.key
      end
    end

    def store_union(redis)
      redis.sunionstore union_key, qualities.map(&:key)
      redis.expire(union_key, UNION_EXPIRATION_PERIOD)
    end

    private

    def union_key
      @_key ||= "#{RediSet.prefix}.union:#{SecureRandom.uuid}"
    end
  end
end
