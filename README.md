signed_json
============

Encodes and decodes data to a JSON string signed with OpenSSL HMAC. Great for signed cookies.


Install.
--------
    gem install signed_json


Use.
----
    require 'signed_json'
    s = SignedJson::Signer.new('your secret')

    ### encode ###
    s.encode 'a string'
    s.encode ['an', 'array']
    s.encode :a => 'hash'

    ### decode ###
    s.decode '["da7555389d05e04a3367b84aed401cafbbecfe3d","example"]'
    # => "example"
    s.decode '["da7555389d05e04a3367b84aed401cafbbecfe3d","tampered"]'
    # SignedJson::SignatureError


Understand.
-----------

`SignedJson::Signer` takes any JSON encodable data, and returns the data in a JSON string along with an [HMAC][1] signature.  The output string can then be decoded back into the original data, with certainty that it was generated using the same secret.

The signature uses [`OpenSSL::HMAC`][2], with the configurable digest defaulting to SHA1.

Note that the data is *not* encrypted - it is clearly readable, but altering the data will cause the signature verification to fail.  The encoded output looks like this:

    ["f47bd6c4108cf503b98b82b2e36ce3e7bae712b5",["an","array","of","strings"]]

This is ideal for signed cookies, and allows client cookies to be used as a light-weight session store.

Rails already has a nice signed cookie implementation, but because [`ActiveSupport::MessageVerifier`][3] uses Base64 encoded Marshal.dump instead of JSON, it is barely portable between Ruby versions, let alone different platforms.

`SignedJson::Signer`, on the other hand, can easily be implemented in other languages, allowing for signed cookies shared between same-domain web applications, for example.

Note that the JSON-encoding must be consistent across implementations.  For example in Python, separators=(',',':') must be specified to eliminate whitespace which would invalidate the HMAC digest.


  [1]: http://en.wikipedia.org/wiki/HMAC
  [2]: http://ruby-doc.org/ruby-1.9/classes/OpenSSL/HMAC.html
  [3]: http://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html


Status.
-------

Ported from my PHP implementation, which is running in high-traffic production environments.

RSpec speaks for the Ruby implementation:

    $ rake spec
    
    SignedJson
      round trip encoding/decoding
        round-trips a string
        round-trips an array of strings and ints
        round-trips a hash with string keys, string and int values
        round-trips a nested array
        round-trips a hash/array/string/int structure
      Signer#encode
        returns a string
        returns a valid JSON-encoded array
      Signer#decode error handling
        raises SignatureError for incorrect key/signature
        raises InputError for invalid input
    
    Finished in 0.0186 seconds
    9 examples, 0 failures

Tested against:

    ruby 1.9.2p0 (2010-08-18 revision 29036) [x86_64-linux]
    rubinius 1.1.0 (1.8.7 release 2010-09-23 JI) [x86_64-unknown-linux-gnu]
    ruby 1.8.7 (2010-08-16 patchlevel 302) [x86_64-linux]
    jruby 1.5.3 (ruby 1.8.7 patchlevel 249) (2010-09-28 7ca06d7) (Java HotSpot(TM) 64-Bit Server VM 1.6.0_22) [amd64-java]


Meh.
----

(c) 2010 Paul Annesley, MIT license.
