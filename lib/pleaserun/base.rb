require "shellwords" # stdlib
require "insist"
require "mustache"
require "pleaserun/namespace"
require "pleaserun/settings"

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

  def template_path
    return File.join("templates", platform, target_version)
  end

  def render_template(name)
    # return a default if not possible? Error if no existing?
    path = File.join(template_path, name)
    raise "Invalid template #{path}!" if !(File.readable?(path) && File.file?(path))
    tmpl = File.read(path)
    return Mustache.render(tmpl, self)
  end # def render_template

  def safe_filename(str)
    return Mustache.render(str, self).gsub(" ","_")
  end # def safe_filename

  def escaped_args
    return Shellwords.shellescape(Shellwords.shelljoin(@args))
  end # def escaped_args

  def escaped(str)
    return Shellwords.shellescape(Mustache.render(str, self))
  end # def escaped
end
