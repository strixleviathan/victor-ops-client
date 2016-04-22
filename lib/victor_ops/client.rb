require 'victor_ops/defaults'
require 'victor_ops/client/version'
require 'victor_ops/client/exceptions'
require 'victor_ops/client/persistence'

module VictorOps
  class Client
    require 'ostruct'
    require 'json'
    require 'rest-client'

    attr_accessor :settings

    def initialize(opts)
      @settings = OpenStruct.new opts
      set_default_settings
      configure_data_store unless settings.persist.nil?
      raise VictorOps::Client::MissingSettings unless valid_settings?
    end

    def entity_display_name
      if settings.entity_display_name.nil?
        "#{settings.host}/#{settings.name}"
      else
        settings.entity_display_name
      end
    end

    def entity_id
      if settings.entity_id.nil?
        entity_display_name
      else
        settings.entity_id
      end
    end

    def entity_display_name=(str)
      settings.entity_display_name = str
    end

    def monitoring_tool
      if settings.monitoring_tool.nil?
        "#{settings.routing_key}::#{settings.name}"
      else
        settings.monitoring_tool
      end
    end

    def monitoring_tool=(str)
      settings.monitoring_tool = str
    end

    def critical(data)
      post critical_payload(data)
    end

    def warn(data)
      post warn_payload(data)
    end

    def info(data)
      post info_payload(data)
    end

    def ack(data)
      post ack_payload(data)
    end

    def recovery(data)
      post recovery_payload(data)
    end

  private

    def epochtime
      Time.now.to_i
    end

    def set_default_settings
      settings.host = VictorOps::Defaults::HOST if settings.host.nil?
      settings.name = VictorOps::Defaults::NAME if settings.name.nil?
    end

    def endpoint
      "#{settings.api_url}/#{settings.routing_key}"
    end

    def post(payload)
      resp = nil
      begin
        json = RestClient::Request.execute method: :post, url: endpoint, payload: payload.to_json, :ssl_version => 'SSLv23'
        resp = JSON::parse(json)
        raise VictorOps::Client::PostFailure, "Response from VictorOps contains a failure message: #{resp.ai}" if resp['result'] == 'failure'
      rescue Exception => e
        raise VictorOps::Client::PostFailure, "Error posting to VictorOps: #{e}"
      end
      resp
    end

    def generate_payload(data)
      if data.nil? || data[:vo_alert_type].nil?
        raise VictorOps::Client::MissingMessageType
      end
      payload = {
        message_type: data.delete(:vo_alert_type),
        state_start_time: epochtime,
        entity_id: entity_id,
        entity_display_name: entity_display_name,
        monitoring_tool: monitoring_tool,
      }
      payload.merge! data
      payload.delete_if { |k,v| v.nil? }
    end

    def critical_payload(data)
      generate_payload data.merge({
        vo_alert_type: VictorOps::Defaults::MessageTypes::CRITICAL,
        state_message: data[:message].nil? ? nil : data.delete(:message)
      })
    end

    def warn_payload(data)
      generate_payload data.merge({
        vo_alert_type: VictorOps::Defaults::MessageTypes::WARN,
        state_message: data[:message].nil? ? nil : data.delete(:message)
      })
    end

    def info_payload(data)
      generate_payload data.merge({
        vo_alert_type: VictorOps::Defaults::MessageTypes::INFO,
        state_message: data[:message].nil? ? nil : data.delete(:message)
      })
    end

    def ack_payload(data)
      generate_payload data.merge({
        vo_alert_type: VictorOps::Defaults::MessageTypes::ACK,
        ack_msg: data[:message].nil? ? nil : data.delete(:message),
        ack_author: data[:author].nil? ? monitoring_tool : data.delete(:author)
      })
    end

    def recovery_payload(data)
      generate_payload data.merge({
        vo_alert_type: VictorOps::Defaults::MessageTypes::RECOVERY,
        state_message: data[:message].nil? ? nil : data.delete(:message)
      })
    end

    def valid_settings?
      valid = true
      [:api_url, :routing_key].each do |k|
        next if valid == false
        valid = false unless settings.send(k)
      end
      settings.api_url.chop! if settings.api_url =~ /\/$/
      valid
    end

  end
end
