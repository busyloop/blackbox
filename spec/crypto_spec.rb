# frozen_string_literal: true
require 'spec_helper'
require 'blackbox/crypto'
require 'base64'

OPENSSL_CIPHERS = %w(aes-128-cbc aes-128-ecb aes-192-cbc aes-192-ecb aes-256-cbc) +
                  %w(aes-256-ecb bf bf-cbc bf-cfb) +
                  %w(bf-ecb bf-ofb cast cast-cbc cast5-cbc) +
                  %w(cast5-cfb cast5-ecb cast5-ofb des des-cbc) +
                  %w(des-cfb des-ecb des-ede des-ede-cbc des-ede-cfb) +
                  %w(des-ede-ofb des-ede3 des-ede3-cbc des-ede3-cfb des-ede3-ofb) +
                  %w(des-ofb des3 desx rc2 rc2-40-cbc) +
                  %w(rc2-64-cbc rc2-cbc rc2-cfb rc2-ecb rc2-ofb) +
                  %w(rc4 rc4-40)

TEST_KEY = '12345678901234567890123456789012'
TEST_IV = 'x234567890123456789012345678901x'
TEST_TEXT_SHORT = '[SHORT_TEST]' * 16
TEST_TEXT_LONG = '[LONG_TEST]' * 8192

describe BB::Crypto do
  OPENSSL_CIPHERS.each do |cipher|
    describe cipher.to_s do
      [[:encrypt, :decrypt],
       [:encrypt_base64, :decrypt_base64],
       [:encrypt_urlsafe_base64, :decrypt_urlsafe_base64]].each do |e|
        m_enc, m_dec = e
        describe "#{m_enc}, #{m_dec}" do
          it 'can decrypt what it encrypted (short string, random iv)' do
            ct = BB::Crypto.send(m_enc, TEST_TEXT_SHORT, TEST_KEY, cipher)
            pt = BB::Crypto.send(m_dec, ct, TEST_KEY, cipher)
            expect(pt).to eq(TEST_TEXT_SHORT)
          end

          it 'can decrypt what it encrypted (long string, random iv)' do
            ct = BB::Crypto.send(m_enc, TEST_TEXT_LONG, TEST_KEY, cipher)
            pt = BB::Crypto.send(m_dec, ct, TEST_KEY, cipher)
            expect(pt).to eq(TEST_TEXT_LONG)
          end

          it 'can decrypt what it encrypted (long string, static iv)' do
            ct = BB::Crypto.send(m_enc, TEST_TEXT_LONG, TEST_KEY, cipher, TEST_IV)
            pt = BB::Crypto.send(m_dec, ct, TEST_KEY, cipher, TEST_IV)
            expect(pt).to eq(TEST_TEXT_LONG)
          end

          it 'returns consistent output with static iv' do
            a = BB::Crypto.send(m_enc, TEST_TEXT_SHORT, TEST_KEY, cipher, TEST_IV)
            b = BB::Crypto.send(m_enc, TEST_TEXT_SHORT, TEST_KEY, cipher, TEST_IV)
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
    TEST_KEY = '12345678901234567890123456789012'
    it "raises an Exception when no key is given and ENV['CONTROLTOKEN_SECRET'] is blank" do
      expect do
        subject.class.create('foo', [])
      end.to raise_error(ArgumentError)
    end

    it 'raises an Exception when key is too short (via parameter)' do
      expect do
        subject.class.create('foo', [], 911, 'key')
      end.to raise_error(OpenSSL::Cipher::CipherError)
    end

    it 'raises an Exception when key is too short (via ENV)' do
      expect do
        ENV['CONTROLTOKEN_SECRET'] = 'x'
        subject.class.create('foo', [], 911)
      end.to raise_error(OpenSSL::Cipher::CipherError)
    end

    it 'decodes all elements of token payload as Strings' do
      v = subject.class.parse(subject.class.create('foo', ['a', 2, :c], 5, TEST_KEY), TEST_KEY)
      expect(v[:op]).to eq('foo')
      expect(v[:args]).to eq(%w(a 2 c))
      expect(v[:expired]).to eq(false)
    end

    it 'raises an Exception when parsing expired Token with force=false' do
      expect do
        subject.class.parse(subject.class.create('foo', ['a', 2, :c], -1, TEST_KEY), TEST_KEY)
      end.to raise_error(ArgumentError)
    end

    it 'returns token with expired=true when parsing expired Token with force=true' do
      v = subject.class.parse(subject.class.create('foo', ['a', 2, :c], -1, TEST_KEY), TEST_KEY, true)
      expect(v[:expired]).to eq(true)
    end
  end
end
