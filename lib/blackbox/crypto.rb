# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'chronic_duration'

module BB
  # Crypto utilities.
  module Crypto
    class << self
      # Encrypt a String.
      #
      # @param [String] plaintext Input String (plaintext)
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] When iv == nil: iv_length+iv+ciphertext
      # @return [String] When iv != nil: ciphertext
      def encrypt(plaintext, key, cipher_type = 'aes-256-cbc', iv = nil)
        cipher = OpenSSL::Cipher.new(cipher_type)
        cipher.encrypt
        cipher.key = key
        if iv.nil?
          iv = cipher.random_iv
          [iv.length].pack('C') + iv + cipher.update(plaintext) + cipher.final
        else
          cipher.iv = iv
          cipher.update(plaintext) + cipher.final
        end
      end

      # Decrypt a String.
      #
      # @param [String] ciphertext Input String (ciphertext)
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] Plaintext
      def decrypt(ciphertext, key, cipher_type = 'aes-256-cbc', iv = nil)
        cipher = OpenSSL::Cipher.new(cipher_type)
        cipher.decrypt
        cipher.key = key
        if iv.nil?
          iv_len = ciphertext.slice!(0).unpack('C')[0]
          cipher.iv = ciphertext.slice!(0..iv_len - 1) unless iv_len == 0
        else
          cipher.iv = iv
        end
        cipher.update(ciphertext) + cipher.final
      end

      # Encrypt a String and encode the resulting ciphertext to Base64.
      #
      # @param [String] plaintext Input String (plaintext)
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] When iv == nil: base64(iv_length+iv+ciphertext)
      # @return [String] When iv != nil: base64(ciphertext)
      def encrypt_base64(plaintext, key, cipher_type = 'aes-256-cbc', iv = nil)
        Base64.strict_encode64(encrypt(plaintext, key, cipher_type, iv))
      end

      # Decode and Decrypt a Base64-String.
      #
      # @param [String] ciphertext Input String (base64(ciphertext))
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] Plaintext
      def decrypt_base64(ciphertext, key, cipher_type = 'aes-256-cbc', iv = nil)
        decrypt(Base64.decode64(ciphertext), key, cipher_type, iv)
      end

      # Encrypt a String and encode the resulting ciphertext to urlsafe Base64.
      #
      # @param [String] plaintext Input String (plaintext)
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] When iv == nil: urlsafe_base64(iv_length+iv+ciphertext)
      # @return [String] When iv != nil: urlsafe_base64(ciphertext)
      def encrypt_urlsafe_base64(plaintext, key, cipher_type = 'aes-256-cbc', iv = nil)
        Base64.urlsafe_encode64(encrypt(plaintext, key, cipher_type, iv))
      end

      # Decode and Decrypt an urlsafe Base64-String.
      #
      # @param [String] ciphertext Input String (urlsafe_base64(ciphertext))
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] Plaintext
      def decrypt_urlsafe_base64(ciphertext, key, cipher_type = 'aes-256-cbc', iv = nil)
        decrypt(Base64.urlsafe_decode64(ciphertext), key, cipher_type, iv)
      end
    end

    # Secure Control Token.
    class ControlToken
      class << self
        # Encode and encrypt an urlsafe ControlToken.
        #
        # @param [String] op Operation id
        # @param [Array] args Arguments (Strings)
        # @param [Fixnum] expire_in
        # @param [String] key Encryption key
        # @param [String] cipher_type OpenSSL cipher
        # @return [String] ControlToken (urlsafe base64)
        def create(op, args, expire_in = 900, key = ENV['CONTROLTOKEN_SECRET'], cipher_type = 'aes-256-cbc')
          raise ArgumentError, 'key can not be blank' if key.nil? || key.empty?
          # If you're reading this in the year 2038: Hi there! :-)
          [Time.now.to_i + expire_in].pack('l<')
          body = ([[Time.now.to_i + expire_in].pack('l<'), op] + args).join("\x00")
          BB::Crypto.encrypt_urlsafe_base64(body, key, cipher_type)
        end

        # Decrypt and parse an urlsafe ControlToken.
        #
        # @param [String] token Input String (urlsafe base64)
        # @param [String] key Encryption key
        # @param [Boolean] force Decode expired token (suppress ArgumentError)
        # @param [String] cipher_type OpenSSL cipher
        # @return [Hash] Token payload
        def parse(token, key = ENV['CONTROLTOKEN_SECRET'], force = false, cipher_type = 'aes-256-cbc')
          raise ArgumentError, 'key can not be blank' if key.nil? || key.empty?
          body = BB::Crypto.decrypt_urlsafe_base64(token, key, cipher_type)
          valid_until, op, *args = body.split("\x00")
          valid_until = valid_until.unpack('l<')[0]
          expired = Time.now.to_i > valid_until
          raise ArgumentError, "Token expired at #{Time.at(valid_until)} (#{ChronicDuration.output(Time.now.to_i - valid_until)} ago)" if expired && !force
          { valid_until: valid_until,
            op: op,
            args: args,
            expired: expired }
        end
      end
    end # /BB::Crypto::Token
  end # /BB::Crypto
end
