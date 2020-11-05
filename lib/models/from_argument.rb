module FromArgument
  extend ActiveSupport::Concern

  class_methods do
    def from_argument(argument, *)
      new(argument)
    end

    def arg_err(key, **interps)
      full_key = "conversions.#{name.underscore}.#{key}"
      raise Commands::RuntimeError.new(full_key, **interps)
    end
  end
end