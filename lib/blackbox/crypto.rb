require 'openssl'
require 'base64'

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
      def encrypt(plaintext, key, cipher_type='aes-256-cbc', iv=nil)
        cipher = OpenSSL::Cipher::Cipher.new(cipher_type)
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
      def decrypt(ciphertext, key, cipher_type='aes-256-cbc', iv=nil)
        cipher = OpenSSL::Cipher::Cipher.new(cipher_type)
        cipher.decrypt
        cipher.key = key
        if iv.nil?
          iv_len = ciphertext.slice!(0).unpack('C')[0]
          unless 0 == iv_len
            cipher.iv = ciphertext.slice!(0..iv_len-1)
          end
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
      def encrypt_base64(plaintext, key, cipher_type='aes-256-cbc', iv=nil)
        Base64.strict_encode64(encrypt(plaintext, key, cipher_type, iv))
      end

      # Decode and Decrypt a Base64-String.
      #
      # @param [String] ciphertext Input String (base64(ciphertext))
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] Plaintext
      def decrypt_base64(ciphertext, key, cipher_type='aes-256-cbc', iv=nil)
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
      def encrypt_urlsafe_base64(plaintext, key, cipher_type='aes-256-cbc', iv=nil)
        Base64.urlsafe_encode64(encrypt(plaintext, key, cipher_type, iv))
      end

      # Decode and Decrypt an urlsafe Base64-String.
      #
      # @param [String] ciphertext Input String (urlsafe_base64(ciphertext))
      # @param [String] key Encryption key
      # @param [String] cipher_type OpenSSL cipher
      # @param [String] iv Initialization vector
      # @return [String] Plaintext
      def decrypt_urlsafe_base64(ciphertext, key, cipher_type='aes-256-cbc', iv=nil)
        decrypt(Base64.urlsafe_decode64(ciphertext), key, cipher_type, iv)
      end
    end
  end
end

