module BB
  # Hash utilities.
  module Hash
    class << self 
      # Symbolize all top level keys.
      #
      # @param [Hash] hash Input hash
      # @return [Hash] Output hash (with symbolized keys)
      def symbolize_keys(hash)
        hash.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
      end

      # Recursively flatten a hash to property-style format.
      # This is a lossy conversion and should only be used for display-purposes.
      #
      # @example
      #   input = { :a => { :b => :c } }
      #   BB::Hash.flatten_prop_style(input)
      #   => {"a.b"=>:c}
      #
      # @example
      #   input = { :a => { :b => [:c, :d, :e] } }
      #   BB::Hash.flatten_prop_style(input)
      #   => {"a.b"=>"c,d,e"}
      #
      # @param [Hash] input Input hash
      # @param [Hash] opts Options
      # @option opts [String] :delimiter
      #   Key delimiter (Default: '.')
      # @param [Hash] output (leave this blank)
      # @return [Hash] Output hash (flattened)
      def flatten_prop_style(input={}, opts={}, output={})
        input.each do |key, value|
          key = opts[:prefix].nil? ? "#{key}" : "#{opts[:prefix]}#{opts[:delimiter]||"."}#{key}"
          case value
          when ::Hash
            flatten_prop_style(value, {:prefix => key, :delimiter => "."}, output)
          when Array
            output[key] = value.join(',')
          else
            output[key] = value
          end
        end
        output
      end
    end
  end
end

