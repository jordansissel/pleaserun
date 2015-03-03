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

    context "#sysv_log" do
      let(:name) { "fancy" }
      before { subject.name = name }

      context "default" do
        it "should be in /var/log" do
          expect(subject.sysv_log).to(be == "/var/log/#{name}")
        end
      end

      context "when given a directory" do
        let(:path) { "/tmp/" }
        before { subject.sysv_log_path = path }
        it "should be <path>/<name>" do
          expect(subject.sysv_log).to(be == File.join(path, subject.name))
        end
      end
      context "when given a path" do
        let(:path) { "/some/path" }
        before { subject.sysv_log_path = path }
        it "should be exactly the path given" do
          expect(subject.sysv_log).to(be == path)
        end
      end
    end
  end
end
