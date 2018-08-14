require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

RSpec.describe VictorOps::Client do
  before do
    @valid_params = { api_url: 'test url', routing_key: 'test key' }
  end

  describe 'settings' do
    before do
      @client = VictorOps::Client.new @valid_params.merge(option: 'this is working')
    end

    it 'should return an OpenStruct hash with the input options hash as settings methods' do
      expect(@client.settings).to be_a(OpenStruct)
      expect(@client.settings.api_url).to eq 'test url'
      expect(@client.settings.routing_key).to eq 'test key'
      expect(@client.settings.option).to eq 'this is working'
      expect(@client.settings.not_a_passed_option).to be_nil
    end
  end

  describe '.monitoring_tool' do
    context 'a parameter is provided on initialization' do
      before do
        @client = VictorOps::Client.new @valid_params.merge(monitoring_tool: 'monitorting tool')
      end

      it 'should return the passed in name' do
        expect(@client.monitoring_tool).to eq 'monitorting tool'
      end
    end

    context 'default initialization' do
      before do
        @client = VictorOps::Client.new @valid_params
      end

      it 'should return the default name' do
        expect(@client.monitoring_tool).to eq 'test key::ruby REST client'
      end
    end
  end

  describe '.monitoring_tool=' do
    it 'should set the entity_display_name name' do
      @client = VictorOps::Client.new @valid_params
      @client.monitoring_tool = 'cool name bro'
      expect(@client.monitoring_tool).to eq 'cool name bro'
    end
  end

  describe '.entity_display_name' do
    context 'a parameter is provided on initialization' do
      before do
        @client = VictorOps::Client.new @valid_params.merge(entity_display_name: 'super cool tool')
      end

      it 'should return the passed in nanme' do
        expect(@client.entity_display_name).to eq 'super cool tool'
      end
    end

    context 'default initialization' do
      before do
        @client = VictorOps::Client.new @valid_params
      end

      it 'should return the default name' do
        expect(@client.entity_display_name).to eq 'localhost/ruby REST client'
      end
    end
  end

  describe '.entity_display_name=' do
    it 'should set the entity_display_name' do
      @client = VictorOps::Client.new @valid_params
      @client.entity_display_name = 'cool name bro'
      expect(@client.entity_display_name).to eq 'cool name bro'
    end
  end

  describe '.critical' do
    before do
      @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
      allow(@client).to receive(:post).and_return(file_fixture_to_json('victor_ops_success.json'))
    end

    it 'should resturn the result of the post to VictorOps' do
      resp = @client.critical(message: 'test')
      expect(resp).to be_a(Hash)
      expect(resp['result']).to eq 'success'
    end
  end

  describe '.warn' do
    before do
      @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
      allow(@client).to receive(:post).and_return(file_fixture_to_json('victor_ops_success.json'))
    end

    it 'should resturn the result of the post to VictorOps' do
      resp = @client.warn(message: 'test')
      expect(resp).to be_a(Hash)
      expect(resp['result']).to eq 'success'
    end
  end

  describe '.info' do
    before do
      @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
      allow(@client).to receive(:post).and_return(file_fixture_to_json('victor_ops_success.json'))
    end

    it 'should resturn the result of the post to VictorOps' do
      resp = @client.info(message: 'test')
      expect(resp).to be_a(Hash)
      expect(resp['result']).to eq 'success'
    end
  end

  describe '.ack' do
    before do
      @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
      allow(@client).to receive(:post).and_return(file_fixture_to_json('victor_ops_success.json'))
    end

    it 'should resturn the result of the post to VictorOps' do
      resp = @client.ack(message: 'test')
      expect(resp).to be_a(Hash)
      expect(resp['result']).to eq 'success'
    end
  end

  describe '.recovery' do
    before do
      @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
      allow(@client).to receive(:post).and_return(file_fixture_to_json('victor_ops_success.json'))
    end

    it 'should resturn the result of the post to VictorOps' do
      resp = @client.recovery(message: 'test')
      expect(resp).to be_a(Hash)
      expect(resp['result']).to eq 'success'
    end
  end

  context 'private methods' do
  	describe '.valid_settings?' do
      context 'settings include required items' do
        before do
          @client = VictorOps::Client.new @valid_params
        end

        it 'should return true' do
          expect(@client.send(:valid_settings?)).to be_truthy
        end
      end

      context 'the api url has a slash at the end' do
        before do
          @client = VictorOps::Client.new api_url: 'slashy/url/', routing_key: 'test key'
        end

        it 'should return true' do
          expect(@client.send(:valid_settings?)).to be_truthy
          expect(@client.settings.api_url).to_not end_with('/')
          expect(@client.settings.api_url).to eq 'slashy/url'
        end
      end

      context 'the api url has no slash at the end' do
        before do
          @client = VictorOps::Client.new api_url: 'no/slashy/url', routing_key: 'test key'
        end

        it 'should return true' do
          expect(@client.send(:valid_settings?)).to be_truthy
          expect(@client.settings.api_url).to_not end_with('/')
          expect(@client.settings.api_url).to eq 'no/slashy/url'
        end
      end

      context 'settings do not include required items' do
        before do
          @client = VictorOps::Client.new @valid_params
          @client.settings.routing_key = nil
        end

        it 'should return false' do
          expect(@client.send(:valid_settings?)).to be_falsey
        end
      end
    end

    describe '.generate_payload' do
      before do
        @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
      end

      context 'a nil hash was passed in' do
        it 'should raise an expetion for no message_type provided' do
          expect { @client.send(:generate_payload, nil) }.to raise_exception(VictorOps::Client::MissingMessageType)
        end
      end

      context 'a hash without required message_type' do
        it 'should raise an expetion for no message_type provided' do
          expect { @client.send(:generate_payload, {stuff: 'test'}) }.to raise_exception(VictorOps::Client::MissingMessageType)
        end
      end

      context 'a properly formed hash is passed in' do
        it 'should return a payload hash' do
          payload = @client.send(:generate_payload, {vo_alert_type: 'TEST'})
          expect(payload[:message_type]).to eq 'TEST'
          expect(payload[:state_start_time]).to be_a(Fixnum)
          expect(payload[:entity_display_name]).to be_a(String)
          expect(payload[:monitoring_tool]).to be_a(String)
        end
      end

      context 'a properly formed hash is passed in with extra variables' do
        it 'should return a payload hash' do
          payload = @client.send(:generate_payload, {vo_alert_type: 'TEST', special_var: 'i am special'})
          expect(payload[:message_type]).to eq 'TEST'
          expect(payload[:special_var]).to eq 'i am special'
          expect(payload[:state_start_time]).to be_a(Fixnum)
          expect(payload[:entity_display_name]).to be_a(String)
          expect(payload[:monitoring_tool]).to be_a(String)
        end
      end

      context 'a properly formed hash is passed in with nil values' do
        it 'should return a payload hash with the nil values removed' do
          payload = @client.send(:generate_payload, {vo_alert_type: 'TEST', special_var: 'i am special', nil_value: nil})
          expect(payload[:message_type]).to eq 'TEST'
          expect(payload[:special_var]).to eq 'i am special'
          expect(payload[:state_start_time]).to be_a(Fixnum)
          expect(payload[:entity_display_name]).to be_a(String)
          expect(payload[:monitoring_tool]).to be_a(String)
          expect(payload.has_key?(:nil_value)).to be_falsey
        end
      end
    end

    context 'utility methods' do
      before do
        @client = VictorOps::Client.new @valid_params
      end

      describe '.epochtime' do
        it 'should return the current time in intenger form' do
          expect(@client.send(:epochtime)).to be_a(Fixnum)
        end
      end

      describe '.set_default_settings' do
        context 'no overides provided' do
          it 'should set the default settings for the client' do
            expect(@client.settings.host).to eq 'localhost'
            expect(@client.settings.name).to eq 'ruby REST client'
          end
        end

        context 'overides provided' do
          before do
            @client = VictorOps::Client.new @valid_params.merge(host: 'db1.com', name: 'jester')
          end

          it 'should set the settings to the overides for the client' do
            expect(@client.settings.host).to eq 'db1.com'
            expect(@client.settings.name).to eq 'jester'
          end
        end
      end

      describe '.endpoint' do
        before do
          @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
        end

        it 'should provide the proper REST endpoint to post to' do
          expect(@client.send(:endpoint)).to eq 'http://victorops.com/1234'
        end
      end

      describe '.post' do
        context 'there is a failure response from VictorOps' do
          before do
            @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
            allow(RestClient).to receive(:post).and_return(file_fixture('victor_ops_failure.json'))
          end

          it 'should raise an exception' do
            expect { @client.send(:post, { test: 'hash' } ) }.to raise_exception(VictorOps::Client::PostFailure)
          end
        end

        context 'there is a failure while posting to VictorOps' do
          before do
            @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
            allow(RestClient).to receive(:post).and_raise(Exception.new('test exception'))
          end

          it 'should raise an exception' do
            expect { @client.send(:post, { test: 'hash' } ) }.to raise_exception(VictorOps::Client::PostFailure)
          end
        end

        context 'the POST is successful' do
          before do
            @client = VictorOps::Client.new api_url: 'http://victorops.com', routing_key: '1234'
            allow(RestClient).to receive(:post).and_return(file_fixture('victor_ops_success.json'))
          end

          it 'return the parsed response' do
            resp = @client.send(:post, { test: 'hash' } )
            expect(resp).to be_a(Hash)
            expect(resp['result']).to eq 'success'
            expect(resp['entity_id']).to be_a(String)
          end
        end
      end

      describe '.critical_payload' do
        it 'should return a Hash without duplicate data' do
          data = @client.send(:critical_payload, message: 'test')
          expect(data).to be_a(Hash)
          expect(data[:message_type]).to eql 'CRITICAL'
          expect(data[:entity_display_name]).to_not be_nil
          expect(data[:monitoring_tool]).to_not be_nil
          expect(data[:state_message]).to eq 'test'
          expect(data[:message]).to be_nil
        end
      end

      describe '.warn_payload' do
        it 'should return a Hash without duplicate data' do
          data = @client.send(:warn_payload, message: 'test')
          expect(data).to be_a(Hash)
          expect(data[:message_type]).to eql 'WARNING'
          expect(data[:entity_display_name]).to_not be_nil
          expect(data[:monitoring_tool]).to_not be_nil
          expect(data[:state_message]).to eq "test"
          expect(data[:message]).to be_nil
        end
      end

      describe '.info_payload' do
        it 'should return a Hash without duplicate data' do
          data = @client.send(:info_payload, message: 'test')
          expect(data).to be_a(Hash)
          expect(data[:message_type]).to eql 'INFO'
          expect(data[:entity_display_name]).to_not be_nil
          expect(data[:monitoring_tool]).to_not be_nil
          expect(data[:state_message]).to eq 'test'
          expect(data[:message]).to be_nil
        end
      end

      describe '.ack_payload' do
        context 'no author provided' do
          it 'should return a Hash without duplicate data' do
            data = @client.send(:ack_payload, message: 'test')
            expect(data).to be_a(Hash)
            expect(data[:message_type]).to eql 'ACKNOWLEDGEMENT'
            expect(data[:entity_display_name]).to_not be_nil
            expect(data[:monitoring_tool]).to_not be_nil
            expect(data[:state_message]).to be_nil
            expect(data[:ack_msg]).to eq 'test'
            expect(data[:ack_author]).to eq data[:monitoring_tool]
            expect(data[:message]).to be_nil
          end
        end

        context 'an author is provieded' do
          it 'should return a Hash without duplicate data' do
            data = @client.send(:ack_payload, message: 'test', author: 'test author')
            expect(data).to be_a(Hash)
            expect(data[:message_type]).to eql 'ACKNOWLEDGEMENT'
            expect(data[:entity_display_name]).to_not be_nil
            expect(data[:monitoring_tool]).to_not be_nil
            expect(data[:state_message]).to be_nil
            expect(data[:ack_msg]).to eq 'test'
            expect(data[:ack_author]).to eq 'test author'
            expect(data[:message]).to be_nil
            expect(data[:author]).to be_nil
          end
        end
      end

      describe '.recovery_payload' do
        it 'should return a Hash without duplicate data' do
          data = @client.send(:recovery_payload, message: 'test')
          expect(data).to be_a(Hash)
          expect(data[:message_type]).to eql 'RECOVERY'
          expect(data[:entity_display_name]).to_not be_nil
          expect(data[:monitoring_tool]).to_not be_nil
          expect(data[:state_message]).to eq 'test'
          expect(data[:message]).to be_nil
        end
      end
    end

  end

end
