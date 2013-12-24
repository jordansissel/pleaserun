require "insist"
require "pleaserun/namespace"

class PleaseRun::Base
  include PleaseRun::Settings

  def initialize(target_version)
    insist { target_version }.is_a?(String)
    @target_version = target_version
    default_settings
  end # def initialize

  def platform
    # The platform name is simply the lowercased class name.
    return self.class.name.split(/::/)[-1].downcase
  end # def platform

  def render_template(name)
    # return a default if not possible? Error if no existing?
    platform = self.class.name

    path = File.join("templates", platform, target_version, name)
    if !(File.readable?(path) && File.file?(path))
    end
  end # def render_template
end
