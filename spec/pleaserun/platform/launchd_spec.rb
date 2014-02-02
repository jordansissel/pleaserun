require "testenv"
require "pleaserun/platform/launchd"

describe PleaseRun::Platform::LaunchD do
  it "inherits correctly" do
    insist { PleaseRun::Platform::LaunchD.ancestors }.include?(PleaseRun::Platform::Base)
  end

  context "#files" do
    subject do
      runner = PleaseRun::Platform::LaunchD.new("10.9")
      runner.name = "fancypants"
      next runner
    end

    let(:files) { subject.files.collect { |path, content| path } }

    it "emits a file in /Library/LaunchDaemons" do
      insist { files }.include?("/Library/LaunchDaemons/fancypants.plist")
    end
  end

  context "#install_actions" do
    subject do
      runner = PleaseRun::Platform::LaunchD.new("10.9")
      runner.name = "fancypants"
      next runner
    end

    it "runs 'launchctl load'" do
      insist { subject.install_actions }.include?("launchctl load /Library/LaunchDaemons/fancypants.plist")
    end
  end

  context "deployment" do
    partytime = (superuser? && platform?("darwin"))
    it "cannot be attempted", :if => !partytime do
      pending("we are not the superuser") unless superuser?
      pending("platform is not darwin") unless platform?("darwin")
    end

    context "as the super user", :if => partytime do
      subject { PleaseRun::Platform::LaunchD.new("10.9") }

      before do
        subject.name = "example"
        subject.user = "root"
        subject.program = "/bin/sh"
        subject.args = [ "-c", "echo hello world; sleep 5" ]

        subject.files.each do |path, content|
          File.write(path, content)
        end
        subject.install_actions.each do |command|
          system(command)
          raise "Command failed: #{command}" unless $?.success?
        end
      end

      after do
        system_quiet("launchctl stop #{subject.name}")
        system_quiet("launchctl unload /Library/LaunchDaemons/#{subject.name}.plist")
        subject.files.each do |path, content|
          File.unlink(path) if File.exist?(path)
        end

        # Remove the logs, too.
        [ "/var/log/#{subject.name}.out", "/var/log/#{subject.name}.err" ].each do |log|
          File.unlink(log) if File.exist?(log)
        end
      end

      it "should install" do
        system_quiet("launchctl list #{subject.name}")
        insist { $? }.success?
      end

      it "should start" do
        system_quiet("launchctl start #{subject.name}")
        insist { $? }.success?
        system_quiet("launchctl list #{subject.name}")
        insist { $? }.success?
      end

      it "should stop" do
        system_quiet("launchctl start #{subject.name}")
        insist { $? }.success?
        system_quiet("launchctl stop #{subject.name}")
        insist { $? }.success?
      end
    end
  end # real tests
end
