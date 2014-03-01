require "testenv"
require "pleaserun/platform/systemd"

describe PleaseRun::Platform::Systemd do
  let(:start) { "systemctl start #{subject.name}.service" }
  let(:stop) { "systemctl stop #{subject.name}.service" }
  let(:status) { "systemctl show #{subject.name} | grep -q SubState=running" }
  let(:restart) { "systemctl restart #{subject.name}.service" }

  it "inherits correctly" do
    insist { PleaseRun::Platform::Systemd.ancestors }.include?(PleaseRun::Platform::Base)
  end

  context "#files" do
    subject do
      runner = PleaseRun::Platform::Systemd.new("default")
      runner.name = "fancypants"
      runner.program = "/bin/true"
      next runner
    end

    let(:files) { subject.files.collect { |path, content| path } }

    it "emits a file in /lib/systemd/system" do
      insist { files }.include?("/lib/systemd/system/fancypants.service")
    end
  end

  context "#install_actions" do
    subject do
      runner = PleaseRun::Platform::Systemd.new("default")
      runner.name = "fancypants"
      next runner
    end

    it "invokes systemctl to reload" do
      insist { subject.install_actions }.include?("systemctl --system daemon-reload")
    end
  end

  context "deployment" do
    partytime = (superuser? && platform?("linux") && program?("systemctl") && File.directory?("/lib/systemd"))
    it "cannot be attempted", :if => !partytime do
      pending("we are not the superuser") unless superuser?
      pending("platform is not linux") unless platform?("linux")
      pending("no 'systemctl' program found") unless program?("systemctl")
      pending("missing /lib/systemd directory") unless File.directory?("/lib/systemd")
    end

    context "as the super user", :if => partytime do
      subject { PleaseRun::Platform::Systemd.new("default") }

      before do
        subject.name = "example"
        subject.user = "root"
        subject.program = "/bin/sh"
        subject.args = [ "-c", "echo hello world; sleep 5" ]
        activate(subject)
        
        # monkeypatch StartLimitInterval=0 into the .service file to avoid
        # being throttled by systemd during these tests.
        # Fixes https://github.com/jordansissel/pleaserun/issues/11
        path = "/lib/systemd/system/#{subject.name}.service"
        File.write(path, File.read(path).sub(/^\[Service\]$/, "[Service]\nStartLimitInterval=0"))
      end

      after do
        system_quiet("systemctl stop #{subject.name}")
        subject.files.each do |path, content|
          File.unlink(path) if File.exist?(path)
        end

        # Remove the logs, too.
        log = "/var/log/upstart/example.log"
        File.unlink(log) if File.exist?(log)
      end

      #it "should install" do
        #system("systemctl status #{subject.name}")
        #status_stopped
      #end

      it "should start" do
        starts
        status_running
      end

      it "should stop" do
        starts
        stops
      end

      it "should start and stop" do
        5.times do
          starts
          stops
        end
      end

      context "with failing prestart" do
        before do
          subject.prestart = "#!/bin/sh\nfalse\n"
          activate(subject)
        end

        it "should fail to start" do
          puts File.read("/lib/systemd/system/example.service")
          system ("ls -l /lib/systemd/system/example-prestart.sh")
          system ("/lib/systemd/system/example-prestart.sh")
          p :prestart => $?
          p File.read("/lib/systemd/system/example-prestart.sh")
          insist { starts }.fails
        end
      end

      context "with successful prestart" do
        before do
          subject.prestart = "true"
          activate(subject)
        end

        it "should start" do
          starts
        end
      end
    end # as the super user
  end # real tests
end
