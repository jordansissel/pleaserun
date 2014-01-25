require "insist"
require "net/ssh"
require "json"
require "stud/try"

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

raise "What tags to run?" if ARGV.empty?
success = true
ARGV.each do |tag|
  name = "pleaserun-testing-container-#{tag}"
  base = File.expand_path("../", File.dirname(__FILE__))

  system("docker start #{name}")

  # If there is no container by this name, let's run one.
  if !$?.success?
    system("docker run -d -name \"#{name}\" -i -t -v \"#{base}:/pleaserun\" jordansissel/system:#{tag} /sbin/init")
  end
  insist { $? }.success?

  begin
    container = JSON.parse(`docker inspect "#{name}"`).first
    vmip = container["NetworkSettings"]["IPAddress"]

    # Wait for ssh to be up
    Stud::try(10.times) { sshrun(vmip, "true") }
    status = sshrun(vmip, ". /etc/profile; cd /pleaserun; bundle install --quiet")
    insist { status } == 0

    status = sshrun(vmip, ". /etc/profile; cd /pleaserun; rspec")
    insist { status } == 0
  ensure
    system("docker kill #{name} > /dev/null 2>&1")
  end
  puts "#{tag}: #{status}"
  success = (status == 0) && success
end

exit(success ? 0 : 1)
