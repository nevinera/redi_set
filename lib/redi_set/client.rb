module RediSet
  class Client
    def initialize(redis_config:)
      @redis = Redis.new(redis_config)
    end

    def match(constraint_hash)
      RediSet::Query.from_hash(constraint_hash).execute(@redis)
    end

    def set_all!(attribute_name, quality_name, ids)
      attribute = Attribute.new(name: attribute_name)
      quality = Quality.new(attribute: attribute, name: quality_name)
      quality.set_all!(@redis, ids)
    end
  end
end
