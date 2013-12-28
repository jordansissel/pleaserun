require "testenv"
require "pleaserun/sysv"

describe PleaseRun::SysVInit do
  it "inherits correctly" do
    insist { PleaseRun::SysVInit.ancestors }.include?(PleaseRun::Base)
  end

  context "#files" do
    subject do
      runner = PleaseRun::SysVInit.new("ubuntu-12.04")
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
