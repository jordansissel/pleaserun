
require "pleaserun/namespace"
require "clamp"
require "cabin"
require "stud/temporary"

require "pleaserun/platform/base"

class PleaseRun::CLI < Clamp::Command
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class PlatformLoadError < Error; end
  class FileWritingFailure < Error; end

  option ["-p", "--platform"], "PLATFORM", "The name of the platform to target, such as sysv, upstart, etc"
  option ["-v", "--version"], "VERSION", "The version of the platform to target, such as 'lsb-3.1' for sysv or '1.5' for upstart",
    :default => "default", :attribute_name => :target_version

  option "--log", "LOGFILE", "The path to use for writing pleaserun logs."
  option "--json", :flag, "Output a result in JSON. Intended to be consumed by other programs. This will emit the file contents and install actions as a JSON object."

  option "--install", :flag, "Install the program on this system. This will write files to the correct location and execute any actions to make the program available to the system."

  PleaseRun::Platform::Base.attributes.each do |facet|
    # Skip program and args which we don't want to make into flags.
    next if [:program, :args, :target_version].include?(facet.name)

    # Turn the attribute name into a flag.
    option "--#{facet.name}", facet.name.to_s.upcase, facet.description,
      :attribute_name => facet.name
  end
  
  # TODO(sissel): Make options based on other platforms

  base = PleaseRun::Platform::Base

  # Load the 'program' attribute from the Base class and use it as the first
  # cli parameter.
  program = base.attributes.find { |f| f.name == :program }
  raise "Something is wrong; Base missing 'program' attribute" if program.nil?
  parameter "PROGRAM", program.description, :attribute_name => program.name

  # Load the 'args' attribute from the Base class
  # and use it as the remaining arguments setting
  args = base.attributes.find { |f| f.name == :args }
  raise "Something is wrong; Base missing 'args' attribute" if program.nil?

  parameter "[ARGS] ...", args.description, :attribute_name => args.name

  def execute
    setup_logger

    if platform.nil?
      require "pleaserun/detector"
      self.platform, self.target_version = PleaseRun::Detector.detect
      @logger.warn("No platform selected. Autodetecting...", :platform => platform, :version => target_version)
    end
    platform_klass = load_platform(platform)

    if name.nil?
      self.name = File.basename(program)
      @logger.warn("No name given, setting reasonable default", :name => self.name)
    end

    # Load the platform implementation
    runner = platform_klass.new(target_version)

    platform_klass.all_attributes.each do |facet|
      # Get the value of this attribute
      # The idea here is to translate CLI options to runner settings
      value = send(facet.name)
      next if value.nil?
      @logger.debug("Setting runner attribute", :name => facet.name, :value => value)

      # Set the value in the runner we've selected
      # This is akin to `obj.someattribute = value`
      runner.send("#{facet.name}=", value)
    end

    if json?
      return run_json(runner)
    else
      return run_human(runner)
    end
    return 0
  rescue Error => e
    @logger.error("An error occurred: #{e}")
    return 1
  end # def execute

  def run_json(runner)
    require "json"

    result = {}
    result["files"] = []
    runner.files.each do |path, content, perms|
      result["files"] << {
        "path" => path,
        "content" => content,
        "perms" => perms
      }
    end

    result["install_actions"] = runner.install_actions

    puts JSON.dump(result)
    return 0
  end # def run_json

  def run_human(runner)
    tmp = Stud::Temporary.directory
    errors = []

    runner.files.each do |path, content, perms|
      #perms ||= (0666 ^ File.umask)
      fullpath = install? ? path : File.join(tmp, path)
      success = write(fullpath, content, perms)
      errors << fullpath unless success
    end

    if errors.any?
      raise FileWritingFailure, "Errors occurred while writing files"
    end

    # TODO(sissel): Refactor this to be less lines of code or put into methods.
    if runner.install_actions.any?
      if install?
        runner.install_actions.each do |action|
          @logger.info("Running install action", :action => action)
          system(action)
          if !$?.success?
            @logger.warn("Install action failed", :action => action, :code => $?.exitstatus)
          end
        end # each install action
      else
        path = File.join(tmp, "install_actions.sh")
        @logger.log("Writing install actions. You will want to run this script to properly activate your service on the target host", :path => path)
        File.open(path, "w") do |fd|
          runner.install_actions.each do |action|
            fd.puts(action)
          end
        end
      end
    end # if runner.install_actions.any?
  end # def run_human

  def write(fullpath, content, perms)
    @logger.log("Writing file", :destination => fullpath)
    FileUtils.mkdir_p(File.dirname(fullpath))
    File.write(fullpath, content)
    @logger.debug("Setting permissions", :destination => fullpath, :perms => perms)
    File.chmod(perms, fullpath) if perms
    return true
  rescue Errno::EACCES
    @logger.error("Access denied in writing a file. Maybe we need to be root?", :path => fullpath)
    return false
  end

  def setup_logger
    @logger = Cabin::Channel.new
    @logger.subscribe(STDERR)
    @logger.level = :warn
  end # def setup_logger

  def load_platform(v)
    @logger.debug("Loading platform", :platform => v)
    platform_lib = "pleaserun/platform/#{v}"
    require(platform_lib)

    const = PleaseRun::Platform.constants.find { |c| c.to_s.downcase == v.downcase }
    if const.nil?
      raise PlatformLoadError, "Could not find platform named '#{v}' after loading library '#{platform_lib}'. This is probably a bug."
    end

    return PleaseRun::Platform.const_get(const)
  rescue LoadError => e
    raise PlatformLoadError, "Failed to find or load platform '#{v}'. This could be a typo or a bug. If it helps, the error is: #{e}"
  end # def load_platform
end # class PleaseRun::CLI
