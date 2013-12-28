require "pleaserun/base"
require "pleaserun/namespace"

class PleaseRun::LaunchD < PleaseRun::Base
  def files
    return Enumerator::Generator.new do |out|
      # Quoting launchctl(1):      
      #    "/Library/LaunchDaemons         System wide daemons provided by the administrator."
      out.yield [ safe_filename("/Library/LaunchDaemons/{{ name }}"), render_template("program.plist") ]
    end
  end

  def install_actions
    return [ 
      "launchctl load #{safe_filename("/Library/LaunchDaemons/{{ name }}")}",
      render("launchctl start {{name}}"),
    ]
  end

  def xml_args
    return if args.nil?
    return args.collect { |a| "<string>#{a}</string>" }.join("")
  end # def xml_args
end

