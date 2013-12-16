require "insist"

module Please; module Run; end; end
class Please::Run::Base
  attr_accessor :name
  attr_accessor :command, :args
  attr_reader :target_version

  def initialize(target_version)
    insist { target_version }.is_a?(String)
    @target_version = target_version
  end

  def command=(command)
    insist { command }.is_a?(String)
    @command = command
  end

  def args=(args)
    insist { args }.is_a?(Array)
    args.each { |a| insist { a }.is_a?(String) }
    @args = args
  end
end
