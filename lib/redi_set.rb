module RediSet
  def self.prefix
    "rs"
  end
end

require "redis"
require "hiredis"
require "redis/connection/hiredis"

require_relative "redi_set/attribute"
require_relative "redi_set/quality"
require_relative "redi_set/constraint"
require_relative "redi_set/query"
require_relative "redi_set/client"
