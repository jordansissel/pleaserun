require 'spec_helper_system'

describe 'basics' do

  context "file creation" do
    let(:value) { rand.to_s }
    let(:path) { "/tmp/x.#{rand.to_s}" }
    before :each do
      File.write(path, value + "\n")
      rcp(:sp => path, :dp => "/tmp/answer")
      File.unlink(path)
    end

    it "should do file copies"  do
      shell 'cat /tmp/answer' do |s|
        s.stdout.should =~ /#{value}/
      end
    end
  end
end

