module RediSet
  class Query
    def initialize(details)
      @constraints = details.map { |key, val| Constraint.new(attribute: key, values: val) }
    end

    attr_reader :constraints

    def execute(redis)
      multi_response = redis.multi do
        constraints.select { |c| c.requires_union? }.each do |c|
          redis.sunionstore c.union_key, *c.set_keys
          redis.expire(c.union_key, 60)
        end

        redis.sinter(constraints.map(&:intersection_key))
      end

      multi_response.last
    end
  end
end
