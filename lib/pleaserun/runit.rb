require 'pleaserun/namespace'
require 'pleaserun/base'

class PleaseRun::RunIt < PleaseRun::Base
  attr_accessor :service_dir, :run_dir

  def initialize(target_platform)
    super(target_platform)

    case target_platform
    when /^(debian|ubuntu)/
      @service_dir = '/etc/service'
      @run_dir     = '/etc/sv'
    end
  end

  def template_path
    return File.join("templates", platform)
  end

  def install_actions
    svdir  = safe_filename("{{ service_dir }}/{{ name }}")
    rundir = safe_filename("{{ run_dir }}/{{ name }}")
    return Enumerator::Generator.new do |enum|
      enum.yield "/bin/ln -s #{svdir} #{rundir}"
    end
  end

  def files
    return Enumerator::Generator.new do |enum|
      enum.yield [ safe_filename("{{ service_dir }}/{{ name }}/run"), render_template('run') ]
      enum.yield [ safe_filename("{{ service_dir }}/{{ name}}/log/run"), render_template('log') ]
    end
  end
end
