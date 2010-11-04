require 'spec_helper'

describe SignedJson do

  describe "round trip encoding/decoding" do

    it "round-trips a string" do
      "a string".should round_trip_as_signed_json
    end

    it "round-trips an array of strings and ints" do
      [1, 'a', 2, 'b'].should round_trip_as_signed_json
    end

    it "round-trips a hash with string keys, string and int values" do
      { 'a' => 'b', 'b' => 2 }.should round_trip_as_signed_json
    end

    it "round-trips a nested array" do
      [ 'a', [ 'b', [ 'c', 'd' ], 'e' ], 'f' ].should round_trip_as_signed_json
    end

    it "round-trips a hash/array/string/int structure" do
      { 'a' => [ 'b' ], 'd' => { 'e' => 'f' }, 'g' => 10 }.should round_trip_as_signed_json
    end

  end

  describe "Signer#encode" do

    it "returns a string" do
      encoded = SignedJson::Signer.new('right').encode('test')
      encoded.should be_instance_of(String)
    end

    it "returns a valid JSON-encoded array" do
      encoded = SignedJson::Signer.new('right').encode('test')
      JSON.parse(encoded).should be_instance_of(Array)
    end

  end

  describe "Signer#decode error handling" do

    it "raises SignatureError for incorrect key/signature" do
      encoded = SignedJson::Signer.new('right').encode('test')
      lambda {
        SignedJson::Signer.new('wrong').decode(encoded)
      }.should raise_error(SignedJson::SignatureError)
    end

    it "raises InputError for invalid input" do
      lambda {
        SignedJson::Signer.new('key').decode('blarg')
      }.should raise_error(SignedJson::InputError)
    end

  end

end
