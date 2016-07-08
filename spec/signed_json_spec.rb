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

    describe "known-good signature from v2.0.0" do
      {
        {"hello" => "world"} => "c9bd3c44a91cfe176f71afcc1e08240555f0ce8b",
        ["hello", "world"] => "67a288435a9268645d399e5969de777096028b2d",
        nil => "546b281dfcf7e69a4dbcb6a5001929585d65c7d7",
        "hello world" => "1ed96f0a1cadcee5bd139eb850d39ac1bcda6747",
        1234 => "307c560360fbf15ecab5a78299052fe68a302d7a",
      }.each do |data, expected|
        it "is #{expected} for #{data.inspect}" do
          encoded = SignedJson::Signer.new("secret").encode(data)
          signature, payload = JSON.parse(encoded)
          expect(signature).to eq(expected)
          expect(payload).to eq(data)
        end
      end
    end

    it "returns known-good signature and payload for object" do
      encoded = SignedJson::Signer.new("secret").encode(hello: "world")
      signature, payload = JSON.parse(encoded)
      expect(signature).to eq("c9bd3c44a91cfe176f71afcc1e08240555f0ce8b")
      expect(payload).to eq({"hello" => "world"})
    end

    it "returns known-good signature and payload for array" do
      encoded = SignedJson::Signer.new("secret").encode(%w(hello world))
      signature, payload = JSON.parse(encoded)
      expect(signature).to eq("67a288435a9268645d399e5969de777096028b2d")
      expect(payload).to eq(["hello", "world"])
    end

    it "returns known-good signature and payload for nil" do
      encoded = SignedJson::Signer.new("secret").encode(nil)
      signature, payload = JSON.parse(encoded)
      expect(signature).to eq("546b281dfcf7e69a4dbcb6a5001929585d65c7d7")
      expect(payload).to eq(nil)
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
