module RR
  module Expectations
    class TimesCalledExpectation
      attr_reader :matcher, :times_called
      
      def initialize(matcher=nil, &time_condition_block)
        raise ArgumentError, "Cannot pass in both an argument and a block" if matcher && time_condition_block
        matcher_value = matcher || time_condition_block
        @matcher = TimesCalledMatchers::TimesCalledMatcher.create(matcher_value)
        @times_called = 0
        @verify_backtrace = caller[1..-1]
      end

      def attempt!
        @times_called += 1
        if(
          @matcher.is_a?(TimesCalledMatchers::TimesCalledMatcher) &&
          !@matcher.possible_match?(@times_called)
        )
          verify_input_error
        end
        return
      end

      def verify
        return false unless @matcher.is_a?(TimesCalledMatchers::TimesCalledMatcher)
        return @matcher.matches?(@times_called)
      end

      def verify!
        unless verify
          if @verify_backtrace
            error = Errors::TimesCalledError.new(error_message)
            error.backtrace = @verify_backtrace
            raise error
          else
            raise Errors::TimesCalledError, error_message
          end
        end
      end

      protected
      def verify_input_error
        raise Errors::TimesCalledError, error_message
      end

      def error_message
        @matcher.error_message(@times_called)
      end
    end
  end
end