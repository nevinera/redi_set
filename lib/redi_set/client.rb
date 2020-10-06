module RediSet
  class Client
    def initialize(redis_config:)
      @redis = Redis.new(redis_config)
    end

    def match(constraint_hash)
      RediSet::Query.from_hash(constraint_hash).execute(@redis)
    end
  end
end
