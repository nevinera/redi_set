Gem::Specification.new do |s|
  s.name = "redi_set"
  s.version = "0.1.1"
  s.summary = "A set-based redis query engine"
  s.description = <<~DESC
    A redis-backed library that makes it easy to find members of a population that
    satisfy a set of attribute constraints using redis set operations.
  DESC

  s.authors = ["Eric Mueller"]
  s.email = "nevinera@gmail.com"
  s.homepage = "https://github.com/nevinera/redi_set"
  s.license = "MIT"

  s.files = Dir["LICENSE", "README.md", "lib/**/*"]

  s.add_dependency "redis"
  s.add_dependency "hiredis"
end
