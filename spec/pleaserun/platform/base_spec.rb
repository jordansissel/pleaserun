require "testenv"
require "pleaserun/platform/base"

describe PleaseRun::Platform::Base do
  context "default" do
    subject { PleaseRun::Platform::Base.new("example") }

    it "#name should be nil" do
      insist { subject.name }.nil?
    end

    it "#args should be nil" do
      insist { subject.args }.nil?
    end

    it "#program should be nil" do
      insist { subject.program }.nil?
    end

    it "#user should be root" do
      insist { subject.user } == "root"
    end

    it "#group should be root" do
      insist { subject.group } == "root"
    end
  end
end

