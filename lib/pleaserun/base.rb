require "insist"

module Please; module Run; end; end
class Please::Run::Base
  attr_accessor :name
  attr_accessor :command, :args
  attr_accessor :user, :group

  attr_reader :target_version

  def initialize(target_version)
    insist { target_version }.is_a?(String)
    @target_version = target_version
    @user = "root"
    @group = "root"
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

  def user=(user)
    insist { user }.is_a?(String)
    @user = user
  end

  def group=(group)
    insist { group }.is_a?(String)
    @group = group
  end
end
