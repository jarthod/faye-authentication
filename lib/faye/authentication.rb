require "faye/authentication/version"

module Faye
  module Authentication

    def self.sign(message, secret)
      channel = message['subscription'] || message['channel']
      OpenSSL::HMAC.hexdigest('sha1', secret, "#{channel}-#{message['clientId']}")
    end

    def self.valid?(message, secret)
      signature = message.delete('signature')
      return false unless signature
      secure_compare(signature, sign(message, secret))
    end

    # constant-time comparison algorithm to prevent timing attacks
    # Copied from ActiveSupport::MessageVerifier
    def self.secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end

  end
end
