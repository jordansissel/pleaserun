require "pleaserun/namespace"
require "pleaserun/configurable"
require "pleaserun/mustache_methods"

require "insist" # gem 'insist'

class PleaseRun::Platform::Base
  include PleaseRun::Configurable
  include PleaseRun::MustacheMethods

  class InvalidTemplate < ::StandardError; end

  attribute :name, "The name of this program." do
    validate do |name|
      insist { name.is_a?(String) }
    end
  end

  attribute :program, "The program to execute. This can be a full path, like " \
    "/usr/bin/cat, or a shorter name like 'cat' if you wish to search $PATH." do
    validate do |program|
      insist { program.is_a?(String) } 
    end
  end

  attribute :args, "The arguments to pass to the program." do
    validate do |args|
      insist { args }.is_a?(Array)
      args.each { |a| insist { a }.is_a?(String) }
    end
  end

  attribute :user, "The user to use for executing this program.",
            :default => "root" do
    validate do |user|
      insist { user }.is_a?(String)
    end
  end

  attribute :group, "The group to use for executing this program.",
            :default => "root" do
    validate do |group|
      insist { group }.is_a?(String)
    end
  end

  attribute :target_version, "The version of this runner platform to target." do
    validate do |version|
      insist { version.is_a?(String) }
    end
  end
  
  attribute :description, "The human-readable description of your program",
            :default => "no description given" do
    validate do |description|
      insist { description }.is_a?(String)
    end
  end

  # TODO(sissel): Should this be a numeric, not a string?
  attribute :umask, "The umask to apply to this program",
            :default => "022" do
    validate do |umask|
      insist { umask }.is_a?(String)
    end
  end

  attribute :chroot, "The directory to chroot to", :default => "/" do
    validate do |chroot|
      insist { chroot }.is_a?(String)
    end
  end

  attribute :chdir, "The directory to chdir to before running" do
    validate do |chdir|
      insist { chdir }.is_a?(String)
    end
  end

  attribute :nice, "The nice level to add to this program before running" do
    validate do |nice|
      insist { nice }.is_a?(Fixnum)
    end
    munge do |nice|
      next nice.to_i
    end
  end

  attribute :prestart, "A command to execute before starting and restarting. A failure of this command will cause the start/restart to abort. This is useful for health checks, config tests, or similar operations."

  def initialize(target_version)
    configurable_setup
    self.target_version = target_version
  end # def initialize

  # Get the platform name for this class.
  # The platform name is simply the lowercased class name, but this can be overridden by subclasses (but don't, because that makes things confusing!)
  def platform
    return self.class.name.split(/::/)[-1].downcase
  end # def platform

  # Get the template path for this platform.
  def template_path
    return File.join(File.dirname(__FILE__), "../../../templates", platform)
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

  # Render a text input through Mustache based on this object.
  def render(text)
    return Mustache.render(text, self)
  end # def render

  # Get a safe-ish filename.
  #
  # This renders `str` through Mustache and replaces spaces with underscores.
  def safe_filename(str)
    return render(str).gsub(" ","_")
  end # def safe_filename

  # The default install_actions is none.
  #
  # Subclasses which need installation actions should implement this method.
  # This method will return an Array of String commands to execute in order
  # to install this given runner.
  #
  # For examples, see launchd and systemd platforms.
  def install_actions
    return []
  end # def install_actions
end # class PleaseRun::Base
