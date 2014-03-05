require "cabin"

# Detect the operating system and version, and based on that information,
# choose the most appropriate runner platform.
# TODO(sissel): Make this a module, not a class.
class PleaseRun::Detector
  class UnknownSystem < StandardError; end

  # A mapping of of [os, version] => [runner, version]
  MAPPING = {
    ["ubuntu", "12.04"] => ["upstart", "1.5"],
    ["ubuntu", "12.10"] => ["upstart", "1.5"],
    ["ubuntu", "13.04"] => ["upstart", "1.5"],
    ["ubuntu", "13.10"] => ["upstart", "1.5"],
    ["debian", "7"] => ["sysv", "lsb-3.1"],
    ["debian", "6"] => ["sysv", "lsb-3.1"],
    ["fedora", "18"] => ["systemd", "default"],
    ["fedora", "19"] => ["systemd", "default"],
    ["fedora", "20"] => ["systemd", "default"]
  }

  def self.detect
    @logger ||= Cabin::Channel.get
    begin
      platform, version = detect_ohai
    rescue LoadError => e
      @logger.debug("Failed to load ohai", :exception => e)
      begin
        platform, version = detect_facter
      rescue LoadError
        raise UnknownSystem
      end
    end

    system = lookup([platform, version])
    raise UnknownSystem if system.nil?
    return system
  end # def self.detect

  def self.lookup(platform_and_version)
    return MAPPING[platform_and_version]
  end # def self.lookup

  def self.detect_ohai
    require "ohai/system"
    ohai = Ohai::System.new
    # TODO(sissel): Loading all plugins takes a long time (seconds). 
    # TODO(sissel): Figure out how to load just the platform plugin correctly.
    ohai.all_plugins

    platform = ohai["platform"]
    version = ohai["platform_version"]

    return platform, normalize_version(platform, version)
  end # def detect_ohai

  def self.normalize_version(platform, version)
    case platform
      # Take '6.0.8' and make it just '6' since debian never makes major
      # changes in a minor release
      when "debian" 
        return version[/^[0-9]+/]
      # TODO(sissel): Any other edge cases?
    end
    return version
  end

  def self.detect_facter
    require "facter"
  end
end
