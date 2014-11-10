require 'spec_helper'

describe SignedJson do

  describe "round trip encoding/decoding" do

    it "round-trips a string" do
      expect("a string").to round_trip_as_signed_json
    end

    it "round-trips an array of strings and ints" do
      expect([1, "a", 2, "b"]).to round_trip_as_signed_json
    end

    it "round-trips a hash with string keys, string and int values" do
      expect({"a" => "b", "b" => 2}).to round_trip_as_signed_json
    end

    it "round-trips a nested array" do
      expect(["a", ["b", ["c", "d"], "e"], "f"]).to round_trip_as_signed_json
    end

    it "round-trips a hash/array/string/int structure" do
      expect({"a" => ["b"], "d" => {"e" => "f"}, "g" => 10}).to round_trip_as_signed_json
    end

  end

  describe "Signer#encode" do

    it "returns a string" do
      encoded = SignedJson::Signer.new('right').encode('test')
      expect(encoded).to be_instance_of(String)
    end

    it "returns a valid JSON-encoded array" do
      encoded = SignedJson::Signer.new('right').encode('test')
      expect(JSON.parse(encoded)).to be_instance_of(Array)
    end

  end

  describe "Signer#decode error handling" do

    it "raises SignatureError for incorrect key/signature" do
      encoded = SignedJson::Signer.new('right').encode('test')
      expect {
        SignedJson::Signer.new('wrong').decode(encoded)
      }.to raise_error(SignedJson::SignatureError)
    end

    it "raises InputError for invalid input" do
      expect {
        SignedJson::Signer.new('key').decode('blarg')
      }.to raise_error(SignedJson::InputError)
    end

    it "raises InputError for nil input" do
      expect {
        SignedJson::Signer.new('key').decode(nil)
      }.to raise_error(SignedJson::InputError)
    end

  end

end
