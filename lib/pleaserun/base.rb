require "insist"
require "pleaserun/namespace"
require "pleaserun/configurable"

require "shellwords" # stdlib
require "mustache"

class PleaseRun::Base
  include PleaseRun::Configurable::Mixin

  attribute :name, "The name of this program." do |name|
    insist { name.is_a?(String) }
  end

  attribute :command, "The program to execute. This can be a full path, like " \
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
            :default => "root"do |group|
    insist { group }.is_a?(String)
  end

  attribute :target_version, "The version of this runner platform to target." do |version|
    insist { version.is_a?(String) }
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
    return File.join("templates", platform, target_version)
  end

  def render_template(name)
    # return a default if not possible? Error if no existing?
    path = File.join(template_path, name)
    raise "Invalid template #{path}!" if !(File.readable?(path) && File.file?(path))
    return render(File.read(path))
  end # def render_template

  def render(text)
    return Mustache.render(text, self)
  end

  def safe_filename(str)
    return render(str).gsub(" ","_")
  end # def safe_filename

  def escaped_args
    return if args.nil?
    return Shellwords.shellescape(Shellwords.shelljoin(args))
  end # def escaped_args

  def escaped(str)
    return Shellwords.shellescape(Mustache.render(str, self))
  end # def escaped
end
