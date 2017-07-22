# frozen_string_literal: true
require 'versionomy'
module BB
  # Gem utilities.
  module Gem
    class << self
      # Return information about the currently installed gem
      # version and the latest available version on rubygems.org.
      #
      # @param [Hash] opts the options to create a message with.
      # @option opts [Fixnum] :check_interval how frequently to query rubygems.org (default: 3600)
      # @option opts [String] :disabling_env_var (default: #{GEMNAME}_DISABLE_VERSION_CHECK)
      # @option opts [] :from ('nobody') From address
      # @return [Hash] result
      #   * :gem_name                => name of current gem
      #   * :gem_installed_version   => installed version
      #   * :gem_latest_version      => latest version on rubygems.org
      #   * :last_checked_for_update => timestamp of last query to rubygems.org
      #   * :next_check_for_update   => timestamp of next query to rubygems.org
      #   * :gem_update_available    => update available?
      #   * :installed_is_latest     => is installed version == latest available version?
      def version_info(*_, **opts)
        ret = {
          gem_name: :unknown,
          gem_installed_version: :unknown,
          gem_latest_version: :unknown,
          gem_update_available: false,
          last_checked_for_update: :unknown,
          next_check_for_update: :unknown,
          installed_is_latest: true
        }

        calling_file = caller[0].split(':')[0]
        spec = ::Gem::Specification.find do |s|
          File.fnmatch(File.join(s.full_gem_path, '*'), calling_file)
        end

        ret[:gem_installed_version] = spec&.version&.to_s || :unknown
        ret[:gem_name] = spec&.name || :unknown

        opts = { # defaults
          check_interval: 3600,
          disabling_env_var: "#{ret[:gem_name].upcase}_DISABLE_VERSION_CHECK"
        }.merge(opts)

        return ret if ret[:gem_name] == :unknown
        return ret if ret[:gem_installed_version] == :unknown
        if opts[:disabling_env_var] && ENV.include?(opts[:disabling_env_var])
          ret[:next_check_for_update] = :never
          return ret
        end

        require 'gem_update_checker'
        require 'tmpdir'
        require 'fileutils'

        statefile_path = File.join(Dir.tmpdir, "#{ret[:gem_name]}-#{ret[:gem_installed_version]}.last_update_check")

        last_check_at = nil
        begin
          last_check_at = File.stat(statefile_path).mtime
        rescue
          last_check_at = Time.at(0)
        end

        ret.merge!(
          last_checked_for_update: last_check_at,
          next_check_for_update: last_check_at + opts[:check_interval]
        )

        return ret if last_check_at + opts[:check_interval] > Time.now && !opts[:force_check]

        checker = GemUpdateChecker::Client.new(ret[:gem_name], ret[:gem_installed_version])
        last_check_at = Time.now

        ret.merge!(
          gem_latest_version: checker.latest_version,
          last_checked_for_update: last_check_at,
          next_check_for_update: last_check_at + opts[:check_interval],
          installed_is_latest: ret[:gem_installed_version] == checker.latest_version,
          gem_update_available: Versionomy.parse(ret[:gem_installed_version]) < Versionomy.parse(checker.latest_version)
        )

        if ret[:installed_is_latest] || opts[:force_check]
          FileUtils.touch(statefile_path, mtime: Time.now)
        else
          ret[:next_check_for_update] = Time.now
        end

        ret
      end
    end
  end
end
