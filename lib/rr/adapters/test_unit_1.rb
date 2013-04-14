module RR
  module Adapters
    class TestUnit1
      module AdapterMethods
        def assert_received(subject, &block)
          block.call(received(subject)).call
        end
      end

      def name
        'Test::Unit 1'
      end

      def applies?
        defined?(::Test::Unit) && !has_test_unit_version?
      end

      def hook
        RR.trim_backtrace = true
        RR.overridden_error_class = ::Test::Unit::AssertionFailedError

        ::Test::Unit::TestCase.class_eval do
          include RRMethods
          include AdapterMethods

          unless instance_methods.detect {|method_name| method_name.to_sym == :setup_with_rr }
            alias_method :setup_without_rr, :setup
            def setup_with_rr
              setup_without_rr
              RR.reset
            end
            alias_method :setup, :setup_with_rr

            alias_method :teardown_without_rr, :teardown
            def teardown_with_rr
              RR.verify
            rescue => e
              teardown_without_rr
              raise e
            end
            alias_method :teardown, :teardown_with_rr
          end
        end
      end

      private

      def has_test_unit_version?
        require 'test/unit/version'
        true
      rescue LoadError
        false
      end
    end
  end

  add_adapter :TestUnit1
end
