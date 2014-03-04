Gem::Specification.new do |spec|
  files = %x{git ls-files}.split("\n")

  spec.name = "pleaserun"
  spec.version = "0.0.1"
  spec.summary = "pleaserun"
  spec.description = "pleaserun"
  spec.license = "Apache 2.0"

  # Note: You should set the version explicitly.
  spec.add_dependency "cabin", ">0" # for logging. apache 2 license
  spec.add_dependency "clamp"
  spec.add_dependency "cabin"
  spec.add_dependency "stud"
  spec.add_dependency "mustache"
  spec.add_dependency "insist"

  spec.files = files
  spec.require_paths << "lib"
  spec.bindir = "bin"
  spec.executables = "pleaserun"

  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  #spec.homepage = "..."
end

