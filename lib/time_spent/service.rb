module TimeSpent

  class Service
    class << self
      def call(*arg, **kwarg, &block)
        new(*arg, **kwarg, &block).()
      end
    end

    def initialize(*arg, **kwarg, &block)
      @arg, @kwarg, @block = arg, kwarg, block
    end

    def call
      fail "#{self.class}.call() must be overriden"
    end
  end

end
