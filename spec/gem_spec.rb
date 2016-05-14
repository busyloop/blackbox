# frozen_string_literal: true
require 'spec_helper'
require 'timecop'
require 'blackbox/gem'

describe BB::Gem do
  describe '.version_info' do
    before :each do
      at = Time.parse('2015-10-21 00:00')
      Timecop.freeze(at) do
        BB::Gem.version_info(force_check: true)
      end
    end

    it 'returns a well-formed Hash' do
      at = Time.parse('2015-10-21 07:28')
      Timecop.freeze(at) do
        retval = BB::Gem.version_info

        expect(retval).to be_a(Hash)
        expect(retval.keys).to contain_exactly(
          :gem_name,
          :gem_installed_version,
          :gem_latest_version,
          :last_checked_for_update,
          :next_check_for_update,
          :installed_is_latest,
          :gem_update_available
        )

        expect(retval).to include(
          gem_name: 'blackbox'
        )

        expect(retval[:gem_installed_version]).not_to eq(:unknown)
        expect(retval[:gem_latest_version]).not_to eq(:unknown)
      end
    end

    it "does not run test before opt['check_interval'] has passed" do
      at = Time.parse('2015-10-21 07:28')
      Timecop.freeze(at) do
        retval = BB::Gem.version_info(check_interval: 864_00)
        expect(retval).to include(
          next_check_for_update: Time.parse('2015-10-22 00:00'),
          gem_latest_version: :unknown

        )
      end
    end

    it "schedules next check according to opt['check_interval']" do
      at = Time.parse('2015-10-21 07:28')
      Timecop.freeze(at) do
        retval = BB::Gem.version_info(check_interval: 60)
        if retval[:installed_is_latest] == false
          expect(retval).to include(
            next_check_for_update: at
          )
        else
          expect(retval).to include(
            next_check_for_update: at + 60
          )
        end
      end
    end

    it 'schedules no check when disabled via env var' do
      ENV['BLACKBOX_DISABLE_VERSION_CHECK'] = '1'
      at = Time.parse('2015-10-21 07:28')
      Timecop.freeze(at) do
        retval = BB::Gem.version_info(check_inverval: 60)
        expect(retval).to include(
          next_check_for_update: :never
        )
      end
    end
  end
end
