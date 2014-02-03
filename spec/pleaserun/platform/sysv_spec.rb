require "testenv"
require "pleaserun/platform/sysv"

describe PleaseRun::Platform::SYSV do
  it "inherits correctly" do
    insist { PleaseRun::Platform::SYSV.ancestors }.include?(PleaseRun::Platform::Base)
  end

  context "#files" do
    subject do
      runner = PleaseRun::Platform::SYSV.new("ubuntu-12.04")
      runner.name = "fancypants"
      next runner
    end

    let(:files) { subject.files.collect { |path, content| path } }

    it "emits a file in /etc/init.d/" do
      insist { files }.include?("/etc/init.d/fancypants")
    end
    it "emits a file in /etc/default/" do
      insist { files }.include?("/etc/default/fancypants")
    end
  end

  context "deployment" do
    partytime = superuser? && File.directory?("/etc/init.d")
    it "cannot be attempted", :if => !partytime do
      pending("we are not the superuser") unless superuser?
      pending("no /etc/init.d/ directory found") unless File.directory?("/etc/init.d")
    end

    context "as the super user", :if => partytime do
      subject { PleaseRun::Platform::SYSV.new("ubuntu-12.04") }

      before do
        subject.name = "example"
        subject.user = "root"
        subject.program = "/bin/ping"
        subject.args = [ "127.0.0.1" ]

        activate(subject)
      end

      after do
        system_quiet("/etc/init.d/#{subject.name} stop")
        subject.files.each do |path, content|
          File.unlink(path) if File.exist?(path)
        end

        # TODO(sissel): Remove the logs, too.
        #log = "/var/log/example.log"
        #File.unlink(log) if File.exist?(log)
      end

      it "should install" do
        insist { File }.exist?("/etc/init.d/#{subject.name}")
      end

      it "should start" do
        # Status should fail before starting
        system_quiet("/etc/init.d/#{subject.name} status")
        reject { $? }.success?

        system_quiet("/etc/init.d/#{subject.name} start")
        insist { $? }.success?

        system_quiet("/etc/init.d/#{subject.name} status")
        insist { $? }.success?
      end

      it "should stop" do
        system_quiet("/etc/init.d/#{subject.name} start")
        insist { $? }.success?

        system_quiet("/etc/init.d/#{subject.name} stop")
        insist { $? }.success?

        system_quiet("/etc/init.d/#{subject.name} status")
        reject { $? }.success?
      end

      context "with failing prestart" do
        before do
          subject.prestart = "false"
          activate(subject)
        end

        it "should fail to start" do
          system_quiet("/etc/init.d/#{subject.name} start")
          reject { $? }.success?
        end

        it "should start if PRESTART=no" do
          system_quiet("env PRESTART=no /etc/init.d/#{subject.name} start")
          insist { $? }.success?
        end

        it "should stop" do
          system_quiet("env PRESTART=no /etc/init.d/#{subject.name} start")
          insist { $? }.success?

          system_quiet("/etc/init.d/#{subject.name} status")
          insist { $? }.success?

          system_quiet("/etc/init.d/#{subject.name} stop")
          insist { $? }.success?

          system_quiet("/etc/init.d/#{subject.name} status")
          reject { $? }.success?
        end

        it "should fail to restart" do
          system_quiet("env PRESTART=no /etc/init.d/#{subject.name} start")
          insist { $? }.success?

          system_quiet("/etc/init.d/#{subject.name} restart")
          reject { $? }.success?
        end
      end

      context "with a successful prestart" do
        before do
          subject.prestart = "echo hello world"
          activate(subject)
        end

        it "should start" do
          system_quiet("/etc/init.d/#{subject.name} start")
          insist { $? }.success?
        end

        it "should restart" do
          system_quiet("env PRESTART=no /etc/init.d/#{subject.name} start")
          insist { $? }.success?

          system_quiet("/etc/init.d/#{subject.name} status")
          insist { $? }.success?

          system_quiet("/etc/init.d/#{subject.name} restart")
          insist { $? }.success?

          system_quiet("/etc/init.d/#{subject.name} status")
          insist { $? }.success?
        end
      end
    end # as the super user
  end # real tests
end
