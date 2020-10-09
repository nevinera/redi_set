module RediSet
  def self.prefix
    configuration.prefix
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :prefix

    def initialize
      @prefix = "rs"
    end
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
