require "pleaserun/namespace"
require "insist"

def superuser?
  return Process::UID.eid == 0
end

def platform?(name)
  return RbConfig::CONFIG["host_os"] =~ /^#{name}/
end

def system_quiet(command)
  system("#{command} > /dev/null 2>&1")
end

def sh(command)
  system_quiet(command)
  return $?
end

def program?(name)
  ENV["PATH"].split(":").each do |path|
    file = File.join(path, name)
    return true if File.executable?(file)
  end
  return false
end

def activate(pleaserun)
  pleaserun.files.each do |path, content, mode=nil|
    File.write(path, content)
    File.chmod(mode, path) if mode
  end
  pleaserun.install_actions.each do |command|
    system(command)
    raise "Command failed: #{command}" unless $?.success?
  end
end

module Helpers
  def starts
    system_quiet(start); insist { $? }.success?
    status_running
  end

  def stops
    system_quiet(stop); insist { $? }.success?
    status_stopped
  end

  def status_running
    system_quiet(status); insist { $? }.success?
  end

  def status_stopped
    system_quiet(status); reject { $? }.success?
  end

  def restarts
    starts
    system_quiet(restart)
    insist { $? }.success?
    status_running
  end
end

RSpec.configure do |c|
  c.include Helpers
end
