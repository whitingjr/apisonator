module TestHelpers
  module Storage
    # Test::Unit hooks, just include TestHelpers::Storage in a testcase if you
    # do not use the global mocking with at_start/at_exit hooks.
    def self.included(base)
      base.singleton_class.instance_eval do
        prepend Hooks
      end
    end

    module Hooks
      def startup
        Mock.mock_storage_client!
        super
      end

      def shutdown
        super
        Mock.unmock_storage_client!
      end
    end
    private_constant :Hooks

    module Mock
      DEFAULT_NODES = ["127.0.0.1:7379", "127.0.0.1:7380"].freeze
      private_constant :DEFAULT_NODES

      class << self
        def set_nodes(*nodes)
          @nodes = nodes.flatten
        end

        def nodes
          @nodes || DEFAULT_NODES
        end

        def mock_storage_client!
          class << ::ThreeScale::Backend::Storage
            # ensure this does not get overwritten
            begin
              const_get(:RedisClientTest)
            rescue NameError
            else
              raise "redefined RedisClientTest"
            end

            # a wrapper class for the Redis client used in tests so that we can
            # address specific Redis instances (as compared to proxies) for flushing.
            class RedisClientTest
              def initialize(inner_client)
                @inner = inner_client
              end

              def keys(*keys)
                non_proxied_instances.map do |i|
                  i.keys(*keys)
                end.flatten(1)
              end

              def flushdb
                non_proxied_instances.map do |i|
                  i.flushdb
                end
              end

              def flushall
                non_proxied_instances.map do |i|
                  i.flushall
                end
              end

              def method_missing(m, *args, &blk)
                # define and delegate the missing method
                self.class.send(:define_method, m) do |*a, &b|
                  inner.send(m, *a, &b)
                end
                inner.send(m, *args, &blk)
              end

              def respond_to_missing?(m)
                inner.respond_to_missing? m
              end

              private

              attr_reader :inner

              def non_proxied_instances
                ::ThreeScale::Backend::Storage.non_proxied_instances
              end
            end
            private_constant :RedisClientTest

            # for testing we need to return a wrapper that catches some specific
            # commands so that they are sent to shards instead to a proxy, because
            # the proxy lacks support for those (these are typically commands to
            # flush the contents of the database).
            alias_method :orig_new, :new

            def new(options)
              RedisClientTest.new orig_new(options)
            end

            def non_proxied_instances
              @non_proxied_instances ||= Mock.nodes.map do |server|
                orig_new(
                  ::ThreeScale::Backend::Storage::Helpers.config_with(
                    configuration.redis,
                    options: { url: server }))
              end
            end
            public :non_proxied_instances
          end
        end

        def unmock_storage_client!
          ::ThreeScale::Backend::Storage.singleton_class.instance_eval do
            remove_const :RedisClientTest
            remove_method :new
            alias_method :new, :orig_new
            remove_method :orig_new
            remove_method :non_proxied_instances
          end
        end
      end
    end
  end
end
