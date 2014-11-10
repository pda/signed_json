require 'json'
require 'signed_json/errors'

module SignedJson
  class Signer

    def initialize(secret, digest = 'SHA1')
      @secret = secret
      @digest = digest
    end

    def encode(input)
      data_to_encode = [digest_for(input), input]
      json_generate(data_to_encode)
    end

    def decode(input)
      digest, data = decode_digest_and_data(input)
      raise SignatureError unless digest === digest_for(data)
      data
    end

    # Generates an HMAC digest for the JSON representation of the given input.
    # JSON generation must be consistent across platforms.
    # e.g. in Python, specify separators=(',',':') to eliminate whitespace.
    def digest_for(input)
      require 'openssl' unless defined?(OpenSSL) # from ActiveSupport::MessageVerifier
      digest = OpenSSL::Digest.const_get(@digest).new
      OpenSSL::HMAC.hexdigest(digest, @secret, json_generate(input))
    end

    private

    def decode_digest_and_data(json)
      parts = json_parse(json)
      unless parts.instance_of?(Array) && parts.length == 2
        raise InputError
      end
      parts
    end

    def json_parse(json)
      JSON.parse(json)
    rescue TypeError, JSON::ParserError
      raise InputError
    end

    def json_generate(data)
      # Use JSON.dump; JSON.generate only handles top-level object/array.
      JSON.dump(data)
    end

  end
end
