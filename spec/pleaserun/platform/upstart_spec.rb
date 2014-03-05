require "testenv"
require "pleaserun/platform/upstart"

describe PleaseRun::Platform::Upstart do
  let(:start) { "initctl start #{subject.name}" }
  let(:stop) { "initctl stop #{subject.name}" }
  let(:status) { "initctl status #{subject.name} | egrep -v '#{subject.name} stop/'" }
  let(:restart) { "initctl restart #{subject.name}" }

  it "inherits correctly" do
    insist { PleaseRun::Platform::Upstart.ancestors }.include?(PleaseRun::Platform::Base)
  end

  context "#files" do
    subject do
      runner = PleaseRun::Platform::Upstart.new("1.10")
      runner.name = "fancypants"
      next runner
    end

    let(:files) { subject.files.collect { |path, content| path } }

    it "emits a file in /etc/init/" do
      insist { files }.include?("/etc/init/fancypants.conf")
    end

    it "emits a file in /etc/init.d/" do
      insist { files }.include?("/etc/init.d/fancypants")
    end
  end

  context "#install_actions" do
    subject do
      runner = PleaseRun::Platform::Upstart.new("1.10")
      runner.name = "fancypants"
      next runner
    end

    it "has no install actions" do
      insist { subject.install_actions }.empty?
    end
  end

  context "deployment" do
    partytime = (superuser? && platform?("linux") && program?("initctl") && File.directory?("/etc/init"))
    it "cannot be attempted", :if => !partytime do
      pending("we are not the superuser") unless superuser?
      pending("platform is not linux") unless platform?("linux")
      pending("no 'initctl' program found") unless program?("initctl")
      pending("missing /etc/init/ directory") unless File.directory?("/etc/init")
    end

    context "as the super user", :if => partytime do
      subject { PleaseRun::Platform::Upstart.new("1.10") }

      before do
        subject.name = "example"
        subject.user = "root"
        subject.program = "/bin/sh"
        subject.args = ["-c", "echo hello world; sleep 5"]
        activate(subject)
      end

      after do
        system_quiet("initctl stop #{subject.name}")
        subject.files.each do |path, content|
          File.unlink(path) if File.exist?(path)
        end

        # Remove the logs, too.
        log = "/var/log/upstart/example.log"
        File.unlink(log) if File.exist?(log)
      end

      it "should start" do
        starts

        # Starting an already-started job will fail
        insist { starts }.fails

        status_running
      end

      it "should stop" do
        starts
        stops
      end

      context "with failing prestart" do
        before do
          subject.prestart = "false"
          activate(subject)
        end

        it "should fail to start" do
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
