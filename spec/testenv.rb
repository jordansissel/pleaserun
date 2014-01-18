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
