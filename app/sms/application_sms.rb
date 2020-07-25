class ApplicationSms
  require 'net/http'
  require 'uri'
  require 'json'


    # ################################################################
    # SMS utils ######################################################
    # ################################################################


    def self.get_logging_oma
=begin
  https://developer.orange.com/apis/sms-mg/getting-started

  curl -X POST \
  -H "Authorization: {{authorization_header}}" \
  -d "grant_type=client_credentials" \
  https://api.orange.com/oauth/v2/token
=end

      uri = URI.parse("https://api.orange.com/oauth/v2/token")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Basic " + ENV['OMA_HEADER_KEY']
      request.set_form_data(
        "grant_type" => "client_credentials",
      )

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end


      puts "Display OMA answer Header " + response.inspect + " <END>"
      puts "Display OMA answer Code " + response.code.inspect + " <END>"
      puts "Display OMA answer Body " + response.body.inspect + " <END>"
      # response.code
      # response.body

      body_read = JSON.parse(response.body)

      puts ">>> body_read: " + body_read.to_s
      puts ">>> body_read token: " + body_read["access_token"].to_s

=begin
Answer is like this
HTTP/1.1 200 OK
Content-Type: application/json
{
    "token_type": "Bearer",
    "access_token": "{{access_token}}",
    "expires_in": "7776000"
}
=end
    end

    def self.send_sms(token)
=begin
https://developer.orange.com/apis/sms-mg/getting-started
curl -X POST -H "Authorization: Bearer {{access_token}}" \
-H "Content-Type: application/json" \
-d '{"outboundSMSMessageRequest":{ \
        "address": "tel:+{{recipient_phone_number}}", \
        "senderAddress":"tel:+{{dev_phone_number}}", \
        "outboundSMSTextMessage":{ \
            "message": "Hello!" \
        } \
    } \
}' \
"https://api.orange.com/smsmessaging/v1/outbound/tel%3A%2B{{dev_phone_number}}/requests"
=end


    uri = URI.parse("https://api.orange.com/smsmessaging/v1/outbound/tel%3A%2B" + ENV['OMA_DEV_NUMBER'] + "/requests")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer " + token
    request.body = JSON.dump({
    "outboundSMSMessageRequest" => {
    "address" => "tel:+{{recipient_phone_number}}",
    "senderAddress" => "tel:+" + ENV['OMA_DEV_NUMBER'],
    "outboundSMSTextMessage" => {
      "message" => "Hello! C'est MG Suivi !"
    }
    }
    })

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end

    # response.code
    # response.body


    end
end
