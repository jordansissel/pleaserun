class PleaseRun::Detector
  class UnknownSystem < StandardError; end

  MAPPING = {
    ["ubuntu", "12.04"] => ["upstart", "1.5"],
    ["ubuntu", "12.10"] => ["upstart", "1.5"],
    ["ubuntu", "13.04"] => ["upstart", "1.5"],
    ["ubuntu", "13.10"] => ["upstart", "1.5"],
    ["debian", "7"] => [ "sysv", "lsb-3.1"],
    ["debian", "6"] => [ "sysv", "lsb-3.1"],
    ["fedora", "18"] => [ "systemd", "default"],
    ["fedora", "19"] => [ "systemd", "default"],
    ["fedora", "120"] => [ "systemd", "default"]
  }

  def self.detect
    begin
      platform, version = detect_ohai
    rescue LoadError => e
      @logger.debug("Failed to load ohai", :exception => e)
      begin
        platform, version = detect_facter
      rescue LoadError
      end
    end

    raise UnknownSystem if platform.nil? || version.nil?
    system = MAPPING[ [platform, version] ]
    raise UnknownSystem if system.nil?
    return system
  end # def detect

  def self.detect_ohai
    require "ohai/system"
    ohai = Ohai::System.new
    ohai.all_plugins

    platform = ohai["platform"]
    platform_version = ohai["platform_version"]
    version = case platform
      # Take '6.0.8' and make it just '6' since debian never makes major
      # changes in a minor release
      when "debian" ; platform_version[/^[0-9]+/]
      else ; platform_version
    end # case platform

    return platform, version
  end # def detect_ohai

  def self.detect_facter
    require "facter"
  end

end
