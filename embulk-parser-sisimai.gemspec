
Gem::Specification.new do |spec|
  spec.name          = "embulk-parser-sisimai"
  spec.version       = "0.1.0"
  spec.authors       = ["Hiroyuki Sato"]
  spec.summary       = "Sisimai Analyzer parser plugin for Embulk"
  spec.description   = "Parses Sisimai Analyzer files read by other file input plugins."
  spec.email         = ["hsato@archsystem.com"]
  spec.licenses      = ["MIT"]
  # TODO set this: spec.homepage      = "https://github.com/hsato/embulk-parser-sisimai"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  #spec.add_dependency 'YOUR_GEM_DEPENDENCY', ['~> YOUR_GEM_DEPENDENCY_VERSION']
  spec.add_dependency 'sisimai', ['~> 4.15.0']
  spec.add_development_dependency 'embulk', ['>= 0.8.1']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
