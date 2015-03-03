Gem::Specification.new do |spec|
  files = `git ls-files`.split("\n")

  spec.name = "pleaserun"
  spec.version = "0.0.11"
  spec.summary = "pleaserun"
  spec.description = "pleaserun"
  spec.license = "Apache 2.0"

  spec.add_dependency "cabin", ">0" # for logging. apache 2 license
  spec.add_dependency "clamp"
  spec.add_dependency "stud"
  spec.add_dependency "mustache", "0.99.8"
  spec.add_dependency "insist"
  #spec.add_dependency "ohai", "~> 6.20" # used for host detection

  spec.files = files
  spec.require_paths << "lib"
  spec.bindir = "bin"
  spec.executables = "pleaserun"

  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  spec.homepage = "https://github.com/jordansissel/pleaserun"
end
