module Commands
  class CalcCommand < Command
    register %w[calc calculate math]

    args split: :spaces do |a|
      a.arg :equation, String
    end

    CONSTANTS = {
      pi:  Math::PI,
      tau: Math::PI * 2,
      e:   Math::E,
    }

    SYMBOL_REPLACEMENTS = {
      /÷/ => '/',
      / x / => ' * ',
    }

    Dentaku.aliases = {
      sqrt: ['sq'],
      # not technically mathematically accurate, but ln = log if no second arg
      log: ['ln'], 
    }

    def call(equation:)
      make_replacements(equation)
      result = Dentaku!(equation, **CONSTANTS)
      print_result(result)
    rescue => e
      print_error(e)
    end

    private

    def make_replacements(equation)
      SYMBOL_REPLACEMENTS.each { |inp, out| equation.gsub!(inp, out) }
    end

    def print_result(result)
      embed do |e|
        e.color = Porygon::COLORS.info
        e.title = t('result')
        e.desc  = result
      end
    end

    def print_error(error)
      message = get_error_message(error)

      embed do |e|
        e.color = Porygon::COLORS.error
        e.title = t('errors.title')
        e.desc  = message
      end
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def get_error_message(error)
      case error
      when Dentaku::UnboundVariableError
        vars = error.unbound_variables
        t 'errors.unbound_variable', count: vars.size,
                                     vars: map_to_code(vars).to_sentence,
                                     prefix: Bot.prefix
      when Dentaku::ParseError
        case error.reason
        when :undefined_function
          t('errors.parse.undefined_function', func: error.meta[:function_name])
        when :too_many_operands
          t('errors.parse.too_many_operands')
        when :too_few_operands
          t('errors.parse.too_few_operands')
        else
          t('errors.unknown')
        end
      when Dentaku::TokenizerError
        case error.reason
        when :too_many_opening_parentheses
          t('errors.token.open_paren')
        when :too_many_closing_parentheses
          t('errors.token.close_paren')
        else
          t('errors.unknown')
        end
      when ZeroDivisionError
        t('errors.div_zero')
      when Math::DomainError
        t('errors.domain')
      else
        t('errors.unknown')
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end