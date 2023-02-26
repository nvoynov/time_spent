require 'date'
require_relative 'service'

module TimeSpent

  module Filter
    extend self

    # build filter
    # @example
    #   Filter.build(period: 'this week', contributor: 'one', project: 'two')
    #
    # @todo --from, --till ... where
    def build(optns)
      optns = optns.dup
      procs = []

      if optns[:period]
        fun = optns.delete(:period).gsub(' ', '_').downcase.to_sym
        mth = method(fun)
        procs << mth.() if mth
      end

      parse_date = proc{|arg| Date.strptime(arg, DATE_PARSE_FORMAT)}
      from_date = optns.delete(:from)
      procs << from(:date, parse_date.(from_date)) if from_date
      till_date = optns.delete(:till)
      procs << till(:date, parse_date.(till_date)) if till_date

      procs.concat optns.map{|key, val| eq(key, val)}
      method(:and).(*procs.compact)
    end
    alias :call :build

    def and(*arg)
      proc{|obj| arg.all?{|fu| fu.(obj) == true} }
    end

    def eq(key, val)
      proc{|key, val, obj|
        obj.send(key) == val
      }.curry.(key, val)
    end

    def nq(key, val)
      proc{|key, val, obj|
        obj.send(key) != val
      }.curry.(key, val)
    end

    def in(key, val)
      proc{|key, val, obj|
        val.include? obj.send(key)
      }.curry.(key, val)
    end

    def match(key, val)
      proc{|key, val, obj|
        obj.send(key) =~ val
      }.curry.(key, val)
    end

    def from(key, val)
      proc{|key, val, obj|
        obj.send(key) >= val
      }.curry.(key, val)
    end

    def till(key, val)
      proc{|key, val, obj|
        obj.send(key) <= val
      }.curry.(key, val)
    end

    def today(key = :date)
      proc{|key, obj|
        obj.send(key) == Date.today
      }.curry.(key)
    end
    alias :this_day :today

    def yesterday(key = :date)
      proc{|key, obj|
        obj.send(key) == Date.today.prev_day
      }.curry.(key)
    end
    alias :prev_day :yesterday

    # @todo use cwday → fixnum
    #    Returns the day of calendar week (1-7, Monday is 1).
    def this_week(key = :date)
      proc{|key, obj|
        date = Date.today
        wday = date.cwday
        obj.send(key).between?(
          date - wday + 1,
          date + (7 - wday)
        )
      }.curry.(key)
    end

    def prev_week(key = :date)
      proc{|key, obj|
        date = Date.today.prev_day(7)
        wday = date.cwday
        obj.send(key).between?(
          date - wday + 1,
          date + (7 - wday)
        )
      }.curry.(key)
    end

    def this_month(key = :date)
      proc{|key, obj|
        today = Date.today
        obj.send(key).between?(
          Date.new(today.year, today.month, 1),
          Date.new(today.year, today.month,-1)
        )
      }.curry.(key)
    end

    def prev_month(key = :date)
      proc{|key, obj|
        mago = Date.today.prev_month
        obj.send(key).between?(
          Date.new(mago.year, mago.month, 1),
          Date.new(mago.year, mago.month,-1)
        )
      }.curry.(key)
    end

    def this_year(key = :date)
      proc{|key, obj|
        today = Date.today
        obj.send(key).between?(
          Date.new(today.year, 1, 1),
          Date.new(today.year, 12, 31)
        )
      }.curry.(key)
    end

    def prev_year(key = :date)
      proc{|key, obj|
        yago = Date.today.prev_year
        obj.send(key).between?(
          Date.new(yago.year, 1, 1),
          Date.new(yago.year, 12, 31)
        )
      }.curry.(key)
    end
  end

end
