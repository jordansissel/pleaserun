require "pleaserun/namespace"
require "pleaserun/configurable"
require "pleaserun/mustache_methods"

require "insist" # gem 'insist'

class PleaseRun::Base
  include PleaseRun::Configurable::Mixin
  include PleaseRun::MustacheMethods
  class InvalidTemplate < ::StandardError; end

  attribute :name, "The name of this program." do |name|
    insist { name.is_a?(String) }
  end

  attribute :program, "The program to execute. This can be a full path, like " \
    "/usr/bin/cat, or a shorter name like 'cat' if you wish to search $PATH." do |program|
    insist { program.is_a?(String) }
  end

  attribute :args, "The arguments to pass to the program." do |args|
    insist { args }.is_a?(Array)
    args.each { |a| insist { a }.is_a?(String) }
  end

  attribute :user, "The user to use for executing this program.",
            :default => "root" do |user|
    insist { user }.is_a?(String)
  end

  attribute :group, "The group to use for executing this program.",
            :default => "root" do |group|
    insist { group }.is_a?(String)
  end

  attribute :target_version, "The version of this runner platform to target." do |version|
    insist { version.is_a?(String) }
  end
  
  attribute :description, "The human-readable description of your program",
            :default => "no description given" do |description|
    insist { description }.is_a?(String)
  end

  def initialize(target_version)
    configurable_setup
    self.target_version = target_version
  end # def initialize

  def platform
    # The platform name is simply the lowercased class name.
    return self.class.name.split(/::/)[-1].downcase
  end # def platform

  def template_path
    return File.join("templates", platform)
  end # def template_path

  def render_template(name)
    possibilities = [ 
      File.join(template_path, target_version, name),
      File.join(template_path, "default", name),
      File.join(template_path, name)
    ]

    possibilities.each do |path|
      next if !(File.readable?(path) && File.file?(path))
      return render(File.read(path))
    end

    raise InvalidTemplate, "Could not find template file for '#{name}'. Tried all of these: #{possibilities.inspect}"
  end # def render_template

  def render(text)
    return Mustache.render(text, self)
  end # def render

  def safe_filename(str)
    return render(str).gsub(" ","_")
  end # def safe_filename

  # The default install_actions is none
  def install_actions
    return []
  end # def install_actions
end # class PleaseRun::Base
