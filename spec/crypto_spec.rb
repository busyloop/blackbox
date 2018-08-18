# frozen_string_literal: true

require 'spec_helper'
require 'blackbox/crypto'
require 'base64'

OPENSSL_CIPHERS = %w[aes-128-cbc aes-128-ecb aes-192-cbc aes-192-ecb aes-256-cbc] +
                  %w[aes-256-ecb bf bf-cbc bf-cfb] +
                  %w[bf-ecb bf-ofb cast cast-cbc cast5-cbc] +
                  %w[cast5-cfb cast5-ecb cast5-ofb des des-cbc] +
                  %w[des-cfb des-ecb des-ede des-ede-cbc des-ede-cfb] +
                  %w[des-ede-ofb des-ede3 des-ede3-cbc des-ede3-cfb des-ede3-ofb] +
                  %w[des-ofb des3 desx rc2 rc2-40-cbc] +
                  %w[rc2-64-cbc rc2-cbc rc2-cfb rc2-ecb rc2-ofb] +
                  %w[rc4 rc4-40]

CIPHER_KEY_IV_SIZE = {
  'aes-128-cbc': [16, 16],
  'aes-128-ecb': [16, 1],
  'aes-192-cbc': [24, 16],
  'aes-192-ecb': [24, 1],
  'aes-256-cbc': [32, 16],
  'aes-256-ecb': [32, 1],
  'bf': [16, 8],
  'bf-cbc': [16, 8],
  'bf-cfb': [16, 8],
  'bf-ecb': [16, 1],
  'bf-ofb': [16, 8],
  'cast': [16, 8],
  'cast-cbc': [16, 8],
  'cast5-cbc': [16, 8],
  'cast5-cfb': [16, 8],
  'cast5-ecb': [16, 1],
  'cast5-ofb': [16, 8],
  'des': [8, 8],
  'des-cbc': [8, 8],
  'des-cfb': [8, 8],
  'des-ecb': [8, 1],
  'des-ede': [16, 1],
  'des-ede-cbc': [16, 8],
  'des-ede-cfb': [16, 8],
  'des-ede-ofb': [16, 8],
  'des-ede3': [24, 1],
  'des-ede3-cbc': [24, 8],
  'des-ede3-cfb': [24, 8],
  'des-ede3-ofb': [24, 8],
  'des-ofb': [8, 8],
  'des3': [24, 8],
  'desx': [24, 8],
  'rc2': [16, 8],
  'rc2-40-cbc': [5, 8],
  'rc2-64-cbc': [8, 8],
  'rc2-cbc': [16, 8],
  'rc2-cfb': [16, 8],
  'rc2-ecb': [16, 1],
  'rc2-ofb': [16, 8],
  'rc4': [16, 1],
  'rc4-40': [5, 1]
}.freeze

TEST_KEY = '12345678901234567890123456789012'
TEST_IV = 'x234567890123456789012345678901x'
TEST_TEXT_SHORT = '[SHORT_TEST]' * 16
TEST_TEXT_LONG = '[LONG_TEST]' * 8192

describe BB::Crypto do
  OPENSSL_CIPHERS.each do |cipher|
    describe cipher.to_s do
      [%i[encrypt decrypt],
       %i[encrypt_base64 decrypt_base64],
       %i[encrypt_urlsafe_base64 decrypt_urlsafe_base64]].each do |e|
        m_enc, m_dec = e
        describe "#{m_enc}, #{m_dec}" do
          it 'can decrypt what it encrypted (short string, random iv)' do
            test_key = TEST_KEY[0..CIPHER_KEY_IV_SIZE.fetch(cipher.to_sym)[0] - 1]
            ct = BB::Crypto.send(m_enc, TEST_TEXT_SHORT, test_key, cipher)
            pt = BB::Crypto.send(m_dec, ct, test_key, cipher)
            expect(pt).to eq(TEST_TEXT_SHORT)
          end

          it 'can decrypt what it encrypted (long string, random iv)' do
            test_key = TEST_KEY[0..CIPHER_KEY_IV_SIZE.fetch(cipher.to_sym)[0] - 1]
            ct = BB::Crypto.send(m_enc, TEST_TEXT_LONG, test_key, cipher)
            pt = BB::Crypto.send(m_dec, ct, test_key, cipher)
            expect(pt).to eq(TEST_TEXT_LONG)
          end

          it 'can decrypt what it encrypted (long string, static iv)' do
            test_key = TEST_KEY[0..CIPHER_KEY_IV_SIZE.fetch(cipher.to_sym)[0] - 1]
            test_iv = TEST_IV[0..CIPHER_KEY_IV_SIZE.fetch(cipher.to_sym)[1] - 1]
            test_iv = nil if test_iv.length == 1
            ct = BB::Crypto.send(m_enc, TEST_TEXT_LONG, test_key, cipher, test_iv)
            pt = BB::Crypto.send(m_dec, ct, test_key, cipher, test_iv)
            expect(pt).to eq(TEST_TEXT_LONG)
          end

          it 'returns consistent output with static iv' do
            test_key = TEST_KEY[0..CIPHER_KEY_IV_SIZE.fetch(cipher.to_sym)[0] - 1]
            test_iv = TEST_IV[0..CIPHER_KEY_IV_SIZE.fetch(cipher.to_sym)[1] - 1]
            test_iv = nil if test_iv.length == 1
            a = BB::Crypto.send(m_enc, TEST_TEXT_SHORT, test_key, cipher, test_iv)
            b = BB::Crypto.send(m_enc, TEST_TEXT_SHORT, test_key, cipher, test_iv)
            expect(a).to eq(b)
          end
        end
      end

      describe 'encrypt_base64' do
        it 'returns base64 string' do
          ct = BB::Crypto.encrypt_base64(TEST_TEXT_LONG, TEST_KEY)
          Base64.decode64(ct)
        end
      end

      describe 'encrypt_urlsafe_base64' do
        it 'returns urlsafe base64 string' do
          ct = BB::Crypto.encrypt_urlsafe_base64(TEST_TEXT_LONG, TEST_KEY)
          Base64.urlsafe_decode64(ct)
        end
      end
    end
  end

  describe BB::Crypto::ControlToken do
    test_key = '12345678901234567890123456789012'
    it "raises an Exception when no key is given and ENV['CONTROLTOKEN_SECRET'] is blank" do
      expect do
        subject.class.create('foo', [])
      end.to raise_error(ArgumentError)
    end

    it 'raises an Exception when key is too short (via parameter)' do
      expect do
        subject.class.create('foo', [], 911, 'key')
      end.to raise_error(ArgumentError)
    end

    it 'raises an Exception when key is too short (via ENV)' do
      expect do
        ENV['CONTROLTOKEN_SECRET'] = 'x'
        subject.class.create('foo', [], 911)
      end.to raise_error(ArgumentError)
    end

    it 'decodes all elements of token payload as Strings' do
      v = subject.class.parse(subject.class.create('foo', ['a', 2, :c], 5, test_key), test_key)
      expect(v[:op]).to eq('foo')
      expect(v[:args]).to eq(%w[a 2 c])
      expect(v[:expired]).to eq(false)
    end

    it 'raises an Exception when parsing expired Token with force=false' do
      expect do
        subject.class.parse(subject.class.create('foo', ['a', 2, :c], -1, test_key), test_key)
      end.to raise_error(ArgumentError)
    end

    it 'returns token with expired=true when parsing expired Token with force=true' do
      v = subject.class.parse(subject.class.create('foo', ['a', 2, :c], -1, test_key), test_key, true)
      expect(v[:expired]).to eq(true)
    end
  end
end
