require "testenv"
require "pleaserun/platform/sysv"
require "pleaserun/detector"

describe PleaseRun::Platform::SYSV do
  let(:platform) { PleaseRun::Detector.detect[0] }
  let(:version) { PleaseRun::Detector.detect[1] }

  context "deployment", :sysv => true do
    it_behaves_like PleaseRun::Platform do
      let(:start) { "/etc/init.d/#{subject.name} start" }
      let(:stop) { "/etc/init.d/#{subject.name} stop" }
      let(:status) { "/etc/init.d/#{subject.name} status" }
      let(:restart) { "/etc/init.d/#{subject.name} restart" }
    end
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
end
