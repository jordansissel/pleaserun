require "testenv"
require "pleaserun/user/base"

describe PleaseRun::User::Base do
  subject(:user) { PleaseRun::User::Base.new }
  context "default" do
    it "should fail validation because there is no name" do
      expect { user.validate }.to(raise_error(PleaseRun::Configurable::ValidationError))
    end
  end

  [:name, :platform, :version].each do |attribute|
    let(:method) { "#{attribute}=".to_sym }
    context "###{attribute}=" do
      let(:value) { Flores::Random.text(1..10) }
      it "accepts a string" do
        expect { user.send(method, value) }.not_to(raise_error)
      end
    end
  end

  # Things that can be set to nil
  [:version].each do |attribute|
    let(:method) { "#{attribute}=".to_sym }
    context "###{attribute}=" do
      let(:value) { nil }
      it "accepts nil" do
        expect { user.send(method, value) }.not_to(raise_error)
      end
    end
  end

  context "rendering" do
    let(:platform) { "linux" }
    let(:name) { "example" }
    before do
      user.name = name
      user.platform = platform
    end

    [:name, :platform].each do |attribute|
      it "should have expected #{attribute}" do
        expected = send(attribute) # get the name, platform, whatever
        expect(user.send(attribute)).to(be == expected)
      end
    end

    it "should pass validation" do
      expect { user.validate }.not_to(raise_error)
    end

    context "#render_installer" do
      subject(:render) { user.render_installer }
      it "should be a String" do
        expect(render).to(be_a(String))
      end
    end

    context "#render_remover" do
      subject(:render) { user.render_remover }
      it "should be a String" do
        expect(render).to(be_a(String))
      end
    end
  end
end
