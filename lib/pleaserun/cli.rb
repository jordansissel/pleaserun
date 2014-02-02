
require "pleaserun/namespace"
require "clamp"
require "cabin"

require "pleaserun/platform/base"

class PleaseRun::CLI < Clamp::Command
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class PlatformLoadError < Error; end

  option ["-p", "--platform"], "PLATFORM", "The name of the platform to target, such as sysv, upstart, etc", :required => true

  PleaseRun::Platform::Base.attributes.each do |facet|
    # Skip program and args
    next if [:program, :args].include?(facet.name)

    option "--#{facet.name}", facet.name.to_s.upcase, facet.description,
      :attribute_name => facet.name
  end

  base = PleaseRun::Platform::Base
  program = base.attributes.find { |f| f.name == :program }
  raise "Something is wrong; Base missing 'program' attribute" if program.nil?
  parameter "PROGRAM", program.description, :attribute_name => program.name

  args = base.attributes.find { |f| f.name == :args }
  raise "Something is wrong; Base missing 'args' attribute" if program.nil?
  parameter "[ARGS] ...", args.description, :attribute_name => args.name

  def execute
    setup_logger
    platform_klass = load_platform(platform)

    runner = platform_klass.new("default")
    platform_klass.all_attributes.each do |facet|
      # Get the value of this attribute
      # This is akin to simply calling `someattribute` method.
      value = send(facet.name)
      next if value.nil?
      @logger.debug("Setting runner", :attribute => facet.name, :value => value)

      # Set the value in the runner we've selected
      # This is akin to `obj.someattribute = value`
      runner.send("#{facet.name}=", value)
    end

    return 0
  rescue Error => e
    puts "An error occurred: #{e}"
    return 1
  end

  def setup_logger
    @logger = Cabin::Channel.new
    @logger.subscribe(STDOUT)
    @logger.level = :debug
  end

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
  end
end
