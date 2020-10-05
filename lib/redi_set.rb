module RediSet
  def self.prefix
    "rs"
  end
end

require "redis"
require "hiredis"
require "redis/connection/hiredis"

require_relative "redi_set/constraint"
require_relative "redi_set/query"
