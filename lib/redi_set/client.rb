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

    # details here is a three-layer hash: attribute_name => quality_name => boolean.
    # only specified attribute/qualities will be updated.
    def set_details!(id, details)
      possessed_qualities, lacked_qualities = Quality.collect_from_details(details)
      @redis.multi do
        possessed_qualities.each { |q| @redis.sadd(q.key, id) }
        lacked_qualities.each { |q| @redis.srem(q.key, id) }
      end
    end
  end
end
