# frozen_string_literal: true
require 'lolcat/lol'
require 'thread'
require 'open3'
require 'pty'
require 'rainbow/ext/string'

module BB
  # Unix utilities.
  module Unix
    class << self
      # Run each line of a script in a shell.
      #
      # @param [Hash] script Script
      # @return [Hash] Exit status (depends on mode)
      def run_each(script, opts = {})
        opts = {
          quiet: false,
          failfast: true,
          spinner: nil,
          stream: false
        }.merge(opts)

        @minispinlock ||= Mutex.new
        script.lines.each_with_index do |line, i|
          line.chomp!
          case line[0]
          when '#'
            puts "\n" + line.bright unless opts[:quiet]
          when ':'
            opts[:quiet] = true if line == ':quiet'
            opts[:failfast] = false if line == ':return'
            opts[:spinner]  = nil   if line == ':nospinner'
            if line == ':stream'
              opts[:stream] = true
              opts[:quiet] = false
            end
          end
          next if line.empty? || ['#', ':'].include?(line[0])

          status = nil
          if opts[:stream]
            puts "\n> ".color(:green) + line.color(:black).bright
            rows, cols = STDIN.winsize
            @minispin_disable = false
            @minispin_last_char_at = Time.now
            @tspin ||= Thread.new do
              i = 0
              loop do
                break if @minispin_last_char_at == :end
                if 0.23 > Time.now - @minispin_last_char_at || @minispin_disable
                  sleep 0.1
                  next
                end
                @minispinlock.synchronize do
                  next if @minispin_disable
                  print "\e[?25l"
                  print Paint[' ', '#000', Lol.rainbow(1, i / 3.0)]
                  sleep 0.12
                  print 8.chr
                  print ' '
                  print 8.chr
                  i += 1
                  print "\e[?25h"
                end
              end
            end

            PTY.spawn("stty rows #{rows} cols #{cols}; " + line) do |r, _w, pid|
              begin
                until r.eof?
                  c = r.getc
                  @minispinlock.synchronize do
                    print c
                    @minispin_last_char_at = Time.now
                    c = c.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: "\e") # barf.
                    # hold on when we are (likely) inside an escape sequence
                    @minispin_disable = true  if c.ord == 27 || c.ord < 9
                    @minispin_disable = false if c =~ /[A-Za-z]/ || [13, 10].include?(c.ord)
                  end
                end
              rescue Errno::EIO
                # Linux raises EIO on EOF, cf.
                # https://github.com/ruby/ruby/blob/57fb2199059cb55b632d093c2e64c8a3c60acfbb/ext/pty/pty.c#L519
                nil
              end

              _pid, status = Process.wait2(pid)
              @minispin_last_char_at = :end
              @tspin.join
              @tspin = nil
            end
          else
            opts[:spinner].call(true) if opts[:spinner]
            output, status = Open3.capture2e(line)
            opts[:spinner].call(false) if opts[:spinner]
            color = (status.exitstatus == 0) ? :green : :red
            if status.exitstatus != 0 || !opts[:quiet]
              puts "\n> ".color(color) + line.color(:black).bright
              puts output
            end
          end
          next unless status.exitstatus != 0
          puts "Error, exit #{status.exitstatus}: #{line} (L#{i})".color(:red).bright

          exit status.exitstatus if opts[:failfast]
          return status.exitstatus
        end
        0
      end
    end
  end
end
