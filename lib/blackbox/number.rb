# frozen_string_literal: true
require 'blackbox/hash'

module BB
  # String utilities.
  module Number
    class << self
      STORAGE_UNITS = %w(byte k M G T P E Z Y).freeze

      ##
      # Formats the bytes in +number+ into a more understandable representation
      # (e.g., giving it 1500 yields 1.5k). This method is useful for
      # reporting file sizes to users. This method returns nil if
      # +number+ cannot be converted into a number. You can customize the
      # format in the +options+ hash.
      #
      # @overload to_human_size(number, options={})
      #   @param [Fixnum] number
      #     Number value to format.
      #   @param [Hash] options
      #     Options for formatter.
      #   @option options [Fixnum] :precision (1)
      #     Sets the level of precision.
      #   @option options [String] :separator (".")
      #     Sets the separator between the units.
      #   @option options [String] :delimiter ("")
      #     Sets the thousands delimiter.
      #   @option options [String] :kilo (1024)
      #     Sets the number of bytes in a kilobyte.
      #   @option options [String] :format ("%n%u")
      #     Sets the display format.
      #
      # @return [String] The formatted representation of bytes
      #
      # @example
      #   to_human_size(123)                                          # => 123
      #   to_human_size(1234)                                         # => 1.2k
      #   to_human_size(12345)                                        # => 12.1k
      #   to_human_size(1234567)                                      # => 1.2M
      #   to_human_size(1234567890)                                   # => 1.1G
      #   to_human_size(1234567890123)                                # => 1.1T
      #   to_human_size(1234567, :precision => 2)                     # => 1.18M
      #   to_human_size(483989, :precision => 0)                      # => 473k
      #   to_human_size(1234567, :precision => 2, :separator => ',')  # => 1,18M
      #
      def to_human_size(number, args = {})
        begin
           Float(number)
         rescue
           return nil
         end

        options = BB::Hash.symbolize_keys(args)

        precision ||= (options[:precision] || 1)
        separator ||= (options[:separator] || '.')
        delimiter ||= (options[:delimiter] || '')
        kilo      ||= (options[:kilo] || 1024)
        storage_units_format ||= (options[:format] || '%n%u')

        begin
          if number.to_i < kilo
            storage_units_format.gsub(/%n/, number.to_i.to_s).gsub(/%u/, '')
          else
            max_exp  = STORAGE_UNITS.size - 1
            number   = Float(number)
            exponent = (Math.log(number) / Math.log(kilo)).to_i # Convert to base
            exponent = max_exp if exponent > max_exp # we need this to avoid overflow for the highest unit
            number  /= kilo**exponent

            unit = STORAGE_UNITS[exponent]

            escaped_separator = Regexp.escape(separator)
            formatted_number = with_precision(number,
                                              precision: precision,
                                              separator: separator,
                                              delimiter: delimiter
                                             ).sub(/(#{escaped_separator})(\d*[1-9])?0+\z/, '\1\2').sub(/#{escaped_separator}\z/, '')
            storage_units_format.gsub(/%n/, formatted_number).gsub(/%u/, unit)
          end
        rescue
          number
        end
      end

      ##
      # Formats a +number+ with the specified level of <tt>:precision</tt> (e.g., 112.32 has a precision of 2).
      # This method returns nil if +number+ cannot be converted into a number.
      # You can customize the format in the +options+ hash.
      #
      # @overload with_precision(number, options={})
      #   @param [Fixnum, Float] number
      #     Number value to format.
      #   @param [Hash] options
      #     Options for formatter.
      #   @option options [Fixnum] :precision (3)
      #     Sets the level of precision.
      #   @option options [String] :separator (".")
      #     Sets the separator between the units.
      #   @option options [String] :delimiter ("")
      #     Sets the thousands delimiter.
      #
      # @return [String] The formatted representation of the number.
      #
      # @example
      #   with_precision(111.2345)                    # => 111.235
      #   with_precision(111.2345, :precision => 2)   # => 111.23
      #   with_precision(13, :precision => 5)         # => 13.00000
      #   with_precision(389.32314, :precision => 0)  # => 389
      #   with_precision(1111.2345, :precision => 2, :separator => ',', :delimiter => '.')
      #   # => 1.111,23
      #
      def with_precision(number, args)
        begin
           Float(number)
         rescue
           return nil
         end

        options = BB::Hash.symbolize_keys(args)

        precision ||= (options[:precision] || 3)
        separator ||= (options[:separator] || '.')
        delimiter ||= (options[:delimiter] || '')

        begin
          rounded_number = (Float(number) * (10**precision)).round.to_f / 10**precision
          with_delimiter("%01.#{precision}f" % rounded_number,
                         separator: separator,
                         delimiter: delimiter)
        rescue
          number
        end
      end

      ##
      # Formats a +number+ with grouped thousands using +delimiter+ (e.g., 12,324).
      # This method returns nil if +number+ cannot be converted into a number.
      # You can customize the format in the +options+ hash.
      #
      # @overload with_delimiter(number, options={})
      #   @param [Fixnum, Float] number
      #     Number value to format.
      #   @param [Hash] options
      #     Options for formatter.
      #   @option options [String] :delimiter (", ")
      #     Sets the thousands delimiter.
      #   @option options [String] :separator (".")
      #     Sets the separator between the units.
      #
      # @return [String] The formatted representation of the number.
      #
      # @example
      #   with_delimiter(12345678)                        # => 12,345,678
      #   with_delimiter(12345678.05)                     # => 12,345,678.05
      #   with_delimiter(12345678, :delimiter => ".")     # => 12.345.678
      #   with_delimiter(12345678, :separator => ",")     # => 12,345,678
      #   with_delimiter(98765432.98, :delimiter => " ", :separator => ",")
      #   # => 98 765 432,98
      #
      def with_delimiter(number, args = {})
        begin
           Float(number)
         rescue
           return nil
         end
        options = BB::Hash.symbolize_keys(args)

        delimiter ||= (options[:delimiter] || ',')
        separator ||= (options[:separator] || '.')

        begin
          parts = number.to_s.split('.')
          parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
          parts.join(separator)
        rescue
          number
        end
      end
    end
  end
end
