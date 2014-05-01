require "testenv"
require "pleaserun/platform/upstart"
require "pleaserun/detector"

describe PleaseRun::Platform::Upstart do
  let(:platform) { PleaseRun::Detector.detect[0] }
  let(:version) { PleaseRun::Detector.detect[1] }

  context "deployment", :upstart=> true do
    it_behaves_like PleaseRun::Platform do
      let(:start) { "initctl start #{subject.name}" }
      let(:stop) { "initctl stop #{subject.name}" }
      let(:status) { "initctl status #{subject.name} | egrep -v '#{subject.name} stop/'" }
      let(:restart) { "initctl restart #{subject.name}" }
    end
  end

  context "#files" do
    subject do
      runner = PleaseRun::Platform::Upstart.new(version)
      runner.name = "fancypants"
      next runner
    end

    let(:files) { subject.files.collect { |path, content| path } }

    it "emits a file in /etc/init/" do
      insist { files }.include?("/etc/init/fancypants.conf")
    end

    # This was removed. I don't think we need to provide an /etc/init.d shim anymore.
    # Please let me know if you disagree :)
    #it "emits a file in /etc/init.d/" do
      #insist { files }.include?("/etc/init.d/fancypants")
    #end
  end

  context "#install_actions" do
    subject do
      runner = PleaseRun::Platform::Upstart.new(version)
      runner.name = "fancypants"
      next runner
    end

    it "has no install actions" do
      insist { subject.install_actions }.empty?
    end
  end
end
