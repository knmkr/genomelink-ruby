require 'byebug'
RSpec.describe Genomelink::Oauth do
  subject { Genomelink::Oauth }
  let(:obj) { double("dummy object for client") }

  before do
    allow(subject).to receive(:get_config).with('GENOMELINK_CALLBACK_URL').and_return("test_url")
    allow(subject).to receive_message_chain(:client, :auth_code).and_return(obj)
  end

  context 'authorization_url' do
    it 'should call authorize_url from client.authcode' do
      expect(obj).to receive(:authorize_url).with({
        redirect_uri: "test_url",
        scope: "testing"
      }).and_return("result")
      expect(subject.authorization_url("testing")).to eq "result"
    end
  end

  context 'get_token' do
    it 'should call get_token from client.authcode' do
      expect(obj).to receive(:get_token).with("auth_code", {redirect_uri: "test_url"}).and_return(double("obj", token: "result"))
      expect(subject.get_token("auth_code")).to eq "result"
    end
  end

  context 'client' do
    before do
      allow(subject).to receive(:client).and_call_original
    end
    it 'should create OAuth2::Client object' do
      expect(subject).to receive(:get_config).twice
      expect(OAuth2::Client).to receive(:new)
      subject.send(:client)
    end
  end

  describe 'get_config' do
    before do
      allow(subject).to receive(:get_config).and_call_original
    end
    context 'If the config is present' do
      before do
        stub_const("ENV", {'test' => "result"})
      end
      it 'should get the requested config' do
        expect(subject.send(:get_config,"test")).to eq("result")
      end
    end
    context 'If the config is not present' do
      before do
        stub_const("ENV", {})
      end
      it 'should get raise ConfigNotFound' do
        expect{subject.send(:get_config,"test")}.to raise_error(Genomelink::ConfigNotFound,"Environment variable test not found !" )
      end
    end
  end
end
