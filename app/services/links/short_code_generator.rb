module Links
  class ShortCodeGenerator
    class GenerationError < StandardError; end

    DEFAULT_LENGTH = 7
    MAX_RETRIES = 3

    def self.call(length: DEFAULT_LENGTH)
      validate_length!(length)

      generate_unique_code(length)
    end

    def self.generate_unique_code(length)
      MAX_RETRIES.times do
        candidate = SecureRandom.alphanumeric(length)
        return candidate unless Link.exists?(short_code: candidate)
      end

      raise GenerationError, "Could not generate a unique code after #{MAX_RETRIES} attempts"
    end

    def self.validate_length!(length)
      return if length.between?(1, Link::MAX_CODE_LENGTH)

      raise ArgumentError, "length must be between 1 and #{Link::MAX_CODE_LENGTH}"
    end

    private_class_method :generate_unique_code
    private_class_method :validate_length!
  end
end
