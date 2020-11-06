class Poll
  MAX = 10

  class << self
    def from_argument(error, arg, *)
      question, *options = arg.split(/\s*\|\s*/)

      return error[:one_option]                 if options.size == 1
      return error[:too_many_options, max: MAX] if options.size > MAX

      new(question, options)
    end
  end

  attr_reader :question, :options

  def initialize(question, options = [])
    @question = question
    @options  = options
  end

  def boolean?
    options.empty?
  end

  def size
    options.size
  end

  def map
    options.each_with_index.map { |opt, i| yield opt, i }.presence
  end
end