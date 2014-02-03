class Stud::Try
  # Make Stud::Try quiet.
  def log_failure(*args); end
end

def sshrun(host, command, &block)
  if !block_given?
    block = proc do |fd, data|
      case fd
        when :stdout; $stdout.write(data)
        when :stderr; $stderr.write(data)
      end
    end
  end

  status = 0
  Net::SSH.start(host, "root", :password => "docker.io") do |ssh|
    ssh.open_channel do |channel|
      channel.exec(command) do |channel, success|
        channel.on_data do |c, data|
          block.call(:stdout, data)
        end
        channel.on_extended_data do |c, type, data|
          block.call(:stderr, data)
        end
        channel.on_request("exit-status") do |c, data|
          status = data.read_long
        end
      end
      channel.wait
    end
  end

  return status
end # def sshrun

def test_in_container(tag, commands, outfile, errfile)
  name = "pleaserun-testing-container-#{tag}"
  base = File.expand_path("../", File.dirname(__FILE__))
  out = File.new(outfile, "w+")
  err = File.new(errfile, "w+")

  # Try to start the container
  system("docker start #{name} > /dev/null")

  # If there is no container by this name, let's make one.
  if !$?.success?
    system("docker run -d -name \"#{name}\" -i -t -v \"#{base}:/pleaserun\" jordansissel/system:#{tag} /sbin/init")
  end
  insist { $? }.success?

  begin
    container = JSON.parse(`docker inspect "#{name}"`).first
    vmip = container["NetworkSettings"]["IPAddress"]

    # Wait for ssh to be up
    Stud::try(10.times) { sshrun(vmip, "true") }

    commands.each do |command|
      status = sshrun(vmip, command) do |channel, data|
        case channel
          when :stdout; out.write(data)
          when :stderr; out.write(data)
        end
      end
      insist { status } == 0
    end
  ensure
    system("docker kill #{name} > /dev/null 2>&1")
  end
  return $?.success?
ensure
  out.close unless out.nil?
  err.close unless err.nil?
end
