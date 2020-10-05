module RediSet
  class Query
    attr_reader :constraints

    def self.from_hash(constraint_hash)
      constraints = constraint_hash.map do |key, val|
        Constraint.new(attribute: key, values: Array(val))
      end
      RediSet::Query.new(constraints)
    end

    def initialize(constraints)
      @constraints = constraints
    end

    def execute(redis)
      redis.multi do
        constraints.select(&:requires_union?).each { |c| c.store_union(redis) }
        redis.sinter(constraints.map(&:intersection_key))
      end.last
    end
  end
end
