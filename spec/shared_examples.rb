require "pleaserun/platform/base"
require "insist"

shared_examples_for PleaseRun::Platform do
  it "inherits correctly" do
    insist { described_class.ancestors }.include?(PleaseRun::Platform::Base)
  end

  context "activation" do
    subject { described_class.new(version) }

    before do
      subject.name = "hurray-#{rand(1000)}"
      subject.user = "root"
      subject.program = "/bin/sh"
      subject.args = ["-c", "echo hello world; sleep 5"]
      activate(subject)
      
      # Hack...
      case described_class.name
        when "PleaseRun::Platform::Systemd"
          # monkeypatch StartLimitInterval=0 into the .service file to avoid
          # being throttled by systemd during these tests.
          # Fixes https://github.com/jordansissel/pleaserun/issues/11
          path = "/lib/systemd/system/#{subject.name}.service"
          File.write(path, File.read(path).sub(/^\[Service\]$/, "[Service]\nStartLimitInterval=0"))
        when "PleaseRun::Platform::Launchd"
          # Avoid being throttled during our tests.
          path = subject.daemons_path
          File.write(path, File.read(path).sub(/^<plist>$/, "<plist><key>ThrottleInterval</key><integer>0</integer>"))
      end
    end

    after do
      system_quiet(stop)
      case described_class.name
        when "PleaseRun::Platform::Launchd"
          system_quiet("launchctl unload #{subject.daemons_path}")
          system_quiet("launchctl remove #{subject.name}")
      end
      subject.files.each do |path, _|
        File.unlink(path) if File.exist?(path)
      end
    end

    it "should start" do
      starts
      status_running
    end

    it "should stop" do
      starts
      stops
    end

    it "should start and stop", flapper: true do
      5.times do
        starts
        stops
      end
    end

    context "with prestart", prestart: true do
      context "that is failing" do
        before do
          subject.prestart = "#!/bin/sh\nfalse\n"
          activate(subject)
        end

        it "should fail to start" do
          insist { starts }.fails
        end
      end

      context "that succeeds" do
        before do
          subject.prestart = "true"
          activate(subject)
        end

        it "should start" do
          starts
        end
      end
    end
  end # as the super user
end
