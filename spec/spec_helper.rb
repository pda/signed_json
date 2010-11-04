require 'signed_json'

RSpec::Matchers.define :round_trip_as_signed_json do

  match do |actual|

    signer = SignedJson::Signer.new('some secret')

    @encoded = signer.encode(actual)
    @decoded = signer.decode(@encoded)

    if @encoded == actual
      fail_because :not_encoded
    elsif @decoded != actual
      fail_because :mismatch
    else
      true
    end
  end

  def fail_because(reason_code)
    @reason = reason_code
    false
  end

  failure_message_for_should do |actual|
    if @reason == :not_encoded
      "Expected encoded to be different to original input: #{actual}"
    elsif @reason == :mismatch
      "Expected decoded to equal original input, got '#{@decoded}'"
    end
  end

end
