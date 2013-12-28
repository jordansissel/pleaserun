require "pleaserun/namespace"
require "insist"

module PleaseRun::Settings
  include PleaseRun::Configurable

  attr_reader :target_version
  attr_accessor :name
  attr_accessor :command, :args
  attr_accessor :user, :group

  def default_settings
    @user = "root"
    @group = "root"
  end

  def validate_settings
    insist { @command }.is_a?(String)
    insist { @user }.is_a?(String)
    insist { @group }.is_a?(String)
    insist { @args }.is_a?(Array)
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
