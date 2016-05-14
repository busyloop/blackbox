# frozen_string_literal: true
module BB
  # String utilities.
  module String
    class << self
      # Strip ANSI escape sequences from String.
      #
      # @param [String] text Input string (dirty)
      # @return [String] Output string (cleaned)
      def strip_ansi(text)
        text.gsub(/\x1b(\[|\(|\))[;?0-9]*[0-9A-Za-z]/, '')
            .gsub(/\x1b(\[|\(|\))[;?0-9]*[0-9A-Za-z]/, '')
            .gsub(/(\x03|\x1a)/, '')
      end
    end
  end
end
