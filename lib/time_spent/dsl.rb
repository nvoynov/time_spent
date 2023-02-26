require_relative 'sentry'
require_relative 'sheet'

module TimeSpent

  class DSL

    def self.build(&block)
      dsl = new
      dsl.instance_eval(&block) if block_given?
      dsl.sheet
    end

    def self.from(file)
      text = File.read(file)
      new.tap{|dsl| dsl.instance_eval text}.sheet
    end

    private_class_method :new

    def project(arg)
      @project = MustbeMinStr.(arg, :project)
    end

    def contributor(arg)
      @contributor = MustbeMinStr.(arg, :contributor)
    end

    def hourly_rate(arg)
      @hourly_rate = MustbeRate.(arg, :hourly_rate)
    end

    def date_format(arg)
      @date_format = arg
    end

    def sheet
      @sheet ||= begin
        fail "project must be specified" unless @project
        fail "contributor must be specified" unless @contributor
        fail "hourly_rate must be specified" unless @hourly_rate
        Sheet.new(project: @project,
          contributor: @contributor,
          hourly_rate: @hourly_rate
        )
      end
    end

    def track(date, spent:, task: '#unknown', desc: '', rate: @hourly_rate)
      _date = case date
      when Integer then Date.parse(date.to_s)
      when String then Date.strptime(date, @date_format)
      else fail "usupported date fromat #{date}"
      end

      _spnt = spent.is_a?(String) ? parse_spent(spent) : spent
      sheet << Track.new(date: _date, spent: _spnt, task: task, desc: desc, rate: rate)
    end

    protected

    def parse_spent(str)
      h = scan_spent(str, /(\d*)[Hh]/)
      m = scan_spent(str, /(\d*)[Mm]/)
      msg = ":spent must match /(\d*)[Hh](\d*){1,2}[Mm]/"
      fail ArgumentError, msg if (h + m) == 0
      h * 60 + m
    end

    def scan_spent(str, pat)
      md = str.match(pat)
      md ? md[1].to_i : 0
    end
  end

end
