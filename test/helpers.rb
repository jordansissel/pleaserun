class Stud::Try
  # Make Stud::Try quiet.
  def log_failure(*args); end
end

def test_in_container(tag, commands, outfile, errfile)
  chdir = File.join(File.dirname(__FILE__), "vagrant")
  system("cd #{chdir}; vagrant up #{tag} > #{outfile} 2> #{errfile}")
  insist { $? }.success?

  commands.each do |command|
    cmd = "cd #{chdir}; vagrant ssh #{tag} -- bash -l >> #{outfile} 2>> #{errfile}"
    IO.popen(cmd, "w") do |io|
      io.puts(". /etc/profile")
      io.puts(". ./.bashrc")
      io.puts(". ./.bash_profile")
      io.puts(command)
      io.puts("exit $?")
      io.close_write
    end
    insist { $? } == 0
  end
  return $?.success?
end
