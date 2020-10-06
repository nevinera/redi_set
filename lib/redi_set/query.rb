module RediSet
  class Query
    attr_reader :constraints

    def self.from_hash(constraint_hash)
      constraints = constraint_hash.map do |key, val|
        attribute = Attribute.new(name: key)
        qualities = Array(val).map { |v| Quality.new(attribute: attribute, name: v) }
        Constraint.new(qualities: qualities)
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
