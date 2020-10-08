module RediSet
  class Quality
    attr_reader :attribute, :name

    # parse a layered hash like "attribute_name => { quality_name => possessed? }" into a pair
    # of Arrays of quality objects, one full of qualities they should possess, the other full
    # of qualities they should not possess.
    def self.collect_from_details(details)
      qheld = []
      qlacked = []
      details.each_pair do |attribute_name, attribute_details|
        attribute = Attribute.new(name: attribute_name)
        attribute_details.each_pair do |quality_name, is_held|
          quality = Quality.new(attribute: attribute, name: quality_name)
          if is_held
            qheld << quality
          else
            qlacked << quality
          end
        end
      end
      [qheld, qlacked]
    end

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
