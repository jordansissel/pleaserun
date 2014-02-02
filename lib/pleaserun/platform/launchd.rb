require "pleaserun/platform/base"
require "pleaserun/namespace"

class PleaseRun::Platform::LaunchD < PleaseRun::Platform::Base
  def daemons_path
    return safe_filename("/Library/LaunchDaemons/{{ name }}.plist")
  end

  def files
    return Enumerator::Generator.new do |out|
      # Quoting launchctl(1):      
      #    "/Library/LaunchDaemons         System wide daemons provided by the administrator."
      out.yield [ daemons_path, render_template("program.plist") ]
    end
  end

  def install_actions
    return [ 
      "launchctl load #{daemons_path}",
      #render("launchctl start {{name}}"),
    ]
  end

  def xml_args
    return if args.nil?
    return args.collect { |a| "<string>#{a}</string>" }.join("\n        ")
  end # def xml_args
end

