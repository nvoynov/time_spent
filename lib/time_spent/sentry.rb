# frozen_string_literal: true

module TimeSpent
  # Factory module for guarding method arguments
  #
  # @example
  #
  #   ShortString = Sentry.new(:str, "must be String[3..100]"
  #   ) {|v| v.is_a?(String) && v.size.between?(3,100)}
  #
  #   ShortString.(str)         => "str"
  #   ShortString.(nil)         => ArgumentError ":str must be String[3..100]"
  #   ShortString.error(nil)    => ":str must be String[3..100]"
  #   ShortString.error!(nil)   => ArgumentError":str must be String[3..100]"
  #   ShortString.(nil, :name)  => ArgumentError ":name must be String[3..100]"
  #   ShortString.(nil, 'John Doe', 'Ups!') => ArgumentError ":John Doe Ups!"
  #
  module Sentry

    # creates a new Sentry
    # @param key [Symbol|String] key for error message
    # @param msg [String] error message
    # @param blk [&block] validation block that should return boolen
    # @return [Sentry] based on key, msg, and validation block
    def self.new(key, msg, &blk)
      # origin ;)
      argerror = lambda {|val, msg, cnd|
        fail ArgumentError, msg unless cnd
        val
      }
      Module.new do
        include Sentry
        extend self

        @key = argerror.(key, ":key must be Symbol|String",
          key.is_a?(String) || key.is_a?(Symbol))
        @msg = argerror.(msg, ":msg must be String", msg.is_a?(String))
        @blk = argerror.(blk, "&blk must be provided", block_given?)
      end
    end

    # returns error message for invalid :val
    # @param val [Object] value to be validated
    # @param key [Symbol|String] key for error message
    # @param msg [String] optional error message
    # @return [String] error message for invalid :val or nil when :val is valid
    def error(val, key = @key, msg = @msg)
      ":#{key} #{msg}" unless @blk.(val)
    end

    # guards :val
    # @todo @see Yard!
    # @param val [Object] value to be returned if it valid
    # @param key [Symbol|String] key for error message
    # @param msg [String] optional error message
    # @return [Object] valid :val or raieses ArgumentError when invalid
    def call(val, key = @key, msg = @msg)
      return val if @blk.(val)
      fail ArgumentError, ":#{key} #{msg}", caller[0..-1]
    end
  end

  MustbeDate = Sentry.new(:date, 'must be Date, today or past'
  ) {|val| val.is_a?(Date) && val <= Date.today }

  MustbeSpent = Sentry.new(:spent, 'must be Integer, in minutes no more than 24h'
  ) {|val| val.is_a?(Integer) && val <= 24 * 60 }

  MustbeRate = Sentry.new(:rate, 'must be Integer|Float, no more than 999.9'
  ) {|val| (val.is_a?(Integer) || val.is_a?(Float)) && val <= 999.9 }

  MustbeTask = Sentry.new(:task, 'must be String[4..] that describes work done'
  ) {|val| val.is_a?(String) && val.size > 3 }

  MustbeMinStr = Sentry.new(:task, 'must be String[3..]'
  ) {|val| val.is_a?(String) && val.size > 2 }

end
