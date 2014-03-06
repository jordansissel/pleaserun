
# Some helpful methods for installing a runner.
module PleaseRun::Installer
  def install(runner)
    install_files(runner)
    install_actions(runner)
  end

  def install_files(runner, root = "/")
    errors = []
    runner.files.each do |path, content, perms|
      # TODO(sissel): Force-set default file permissions if not provided?
      # perms ||= (0666 ^ File.umask)
      fullpath = File.join(root, path)
      success = write(fullpath, content, perms)
      errors << fullpath unless success
    end
    raise FileWritingFailure, "Errors occurred while writing files" if errors.any?
  end

  def write(fullpath, content, perms)
    @logger.log("Writing file", :destination => fullpath)
    FileUtils.mkdir_p(File.dirname(fullpath))
    File.write(fullpath, content)
    @logger.debug("Setting permissions", :destination => fullpath, :perms => perms)
    File.chmod(perms, fullpath) if perms
    return true
  rescue Errno::EACCES
    @logger.error("Access denied in writing a file. Maybe we need to be root?", :path => fullpath)
    return false
  end

  def install_actions(runner)
    # TODO(sissel): Refactor this to be less lines of code or put into methods.
    runner.install_actions.each do |action|
      @logger.info("Running install action", :action => action)
      system(action)
      @logger.warn("Install action failed", :action => action, :code => $CHILD_STATUS.exitstatus) unless $CHILD_STATUS.success?
    end # each install action
  end

  def write_actions(runner, path)
    @logger.log("Writing install actions. You will want to run this script to properly activate your service on the target host", :path => path)
    File.open(path, "w") do |fd|
      runner.install_actions.each do |action|
        fd.puts(action)
      end
    end
  end
end # module PleaseRun::Installer
