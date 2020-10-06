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

    def set_all!(redis, ids)
      redis.multi do
        redis.del(key)
        redis.sadd(key, ids)
      end
    end
  end
end
