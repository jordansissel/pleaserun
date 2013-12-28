require "testenv"
require "pleaserun/base"

describe PleaseRun::Base do
  context "default" do
    subject { PleaseRun::Base.new("example") }
    it "#name should be nil" do
      insist { subject.name }.nil?
    end

    it "#args should be nil" do
      insist { subject.args }.nil?
    end

    it "#command should be nil" do
      insist { subject.command }.nil?
    end

    it "#user should be root" do
      insist { subject.user } == "root"
    end

    it "#group should be root" do
      insist { subject.group } == "root"
    end
  end
end
