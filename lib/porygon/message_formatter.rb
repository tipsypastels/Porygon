module Porygon
  module MessageFormatter
    module_function

    def bold(value)
      "**#{value}**"
    end

    def italics(value)
      "_#{value}_"
    end
    
    def code(value)
      "`#{value}`"
    end

    def code_block(value, language = nil, inspect: false)
      "```#{language}\n#{inspect ? value.inspect : value}```"
    end

    def map_to_code(ary)
      ary.map(&method(:code))
    end

    def map_to_code_block(ary)
      ary.map(&method(:code_block))
    end

    def yes_no(bool)
      bool ? 'Yes' : 'No'
    end
  end
end