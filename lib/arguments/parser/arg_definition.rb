module Arguments
  class Parser
    # A definition of an argument used by the parser.
    class ArgDefinition
      attr_reader :name, :type, :default

      def initialize(name, type, default: nil, optional: false)
        @name  = name
        @type  = type

        @default  = default
        @optional = optional
      end

      def validate!
        # no-op
      end

      def >>(other)
        other.args << self
      end

      def optional?
        @optional
      end

      def to_usage(command)
        if default
          wrap_for_usage("#{type_to_usage(command)}=#{default}")
        else
          wrap_for_usage(type_to_usage(command))
        end
      end

      def consume(parser)
        idx, arg, value = type.consume_until_valid(parser)
        idx   || parser.missing(self)
        value ||= convert_to_type(arg, parser)

        parser.set(self, value, 0..idx)
      end

      private

      def type_to_usage(command)
        type.usage(self, command) 
      end

      def wrap_for_usage(string)
        if type.skip_default_usage_wrap?
          return string
        end
        
        if optional? || default
          "[#{string}]"
        else
          "<#{string}>"
        end
      end

      def convert_to_type(value, parser)
        type.call(value, parser.command)
      end
    end
  end
end