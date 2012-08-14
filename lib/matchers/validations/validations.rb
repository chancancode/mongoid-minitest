module Mongoid
  module Matchers
    module Validations
      class HaveValidationMatcher < Matcher
        def initialize(field, validation_type)
          @field = field.to_s
          @type = validation_type.to_s
        end

        def with_message(expected_message)
          @expected_message = expected_message
          self
        end

        def on(*contexts)
          @expected_on = contexts.flatten.compact
          self
        end

        def matches?(subject)
          @klass     = class_of(subject)
          @validator = detect_validator
          @result    = true

          check_validator
          check_message if @expected_message
          check_on if @expected_on

          @result
        end

        def failure_message
          "#{@klass} to #{description}; instead got #{@negative_message}"
        end

        def negative_failure_message
          "#{@klass} to not #{description}; instead got #{@positive_message}"
        end

        def description
          desc = "validate #{@type.inspect} of #{@field.inspect}"
          desc << " with message: #{@expected_message.inspect}" if @expected_message
          desc << " on #{@expected_on.empty? ? 'all actions' : @expected_on.map(&:inspect).join(', ')}" if @expected_on

          desc
        end

        private

        def check_validator
          if @validator
            @negative_message = "#{@type.inspect} validator for #{@field.inspect}"
            @positive_message = "#{@type.inspect} validator for #{@field.inspect}"
          else
            @negative_message = "no #{@type.inspect} validator for #{@field.inspect}"
            @result = false
          end
        end

        def check_message
          error_message = @validator.options[:message]
          if @expected_message == error_message
            @positive_message << " with message: #{error_message.inspect}"
          else
            @negative_message << " with message: #{error_message.inspect}"
            @result = false
          end
        end

        def check_on
          on = [@validator.options[:on]].flatten.compact
          if on.sort == @expected_on.sort
            @positive_message << " on #{on.empty? ? 'all actions' : on.map(&:inspect).join(', ')}"
          else
            @negative_message << " on #{on.empty? ? 'all actions' : on.map(&:inspect).join(', ')}"
            @result = false
          end
        end

        def detect_validator
          @klass.validators_on(@field).detect { |v| v.kind.to_s == @type }
        end
      end
    end
  end
end
