require "cabin"
require "open3"

# Detect the service platform that's most likely to be successful on the
# running machine.
#
# See the `detect` method.
module PleaseRun::Detector
  class UnknownSystem < StandardError; end

  module_function

  def detect
    return @system unless @system.nil?

    @logger ||= Cabin::Channel.get
    @system = detect_platform
    raise UnknownSystem, "Unable to detect which service platform to use" if @system.nil?
    return @system
  end # def self.detect

  def detect_platform
    detect_systemd || detect_upstart || detect_launchd || detect_runit || detect_sysv
  end

  def detect_systemd
    # Expect a certain directory
    return false unless File.directory?("/usr/lib/systemd")

    # Check the version. If `systemctl` fails, systemd isn't available.
    out, status = execute([ "systemctl", "--version" ])
    return false unless status.success?

    # version is the last word on the first line of the --version output
    version = out.split("\n").first.split(/\s+/).last
    ["systemd", version]
  end

  def detect_upstart
    # Expect a certain directory
    return false unless File.directory?("/etc/init")

    # Check the version. If `initctl` fails, upstart isn't available.
    out, status = execute(["initctl", "--version"])
    return false unless status.success?

    version = out.split("\n").first.tr("()", "").split(/\s+/).last
    ["upstart", version]
  end

  def detect_sysv
    return false unless File.directory?("/etc/init.d")

    # TODO(sissel): Do more specific testing.
    ["sysv", "lsb-3.1"]
  end

  def detect_launchd
    return false unless File.directory?("/Library/LaunchDaemons")

    out, status = execute(["launchctl", "version"])
    return false unless status.success?

    # TODO(sissel): Version?
    version = out.split("\n").first.split(":").first.split(/\s+/).last
    ["launchd", version]
  end

  def detect_runit
    return false unless File.directory?("/service")

    # TODO(sissel): Do more tests for runit
  end

  def execute(command)
    Open3.popen3(*command) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      out = stdout.read
      stderr.close
      exit_status = wait_thr.value
      return out, exit_status
    end
  end
end
