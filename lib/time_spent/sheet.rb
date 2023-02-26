module TimeSpent
  class Track
    attr_reader :date, :spent, :task, :desc, :rate

    def initialize(date:, spent:, task:, desc:, rate:)
      @date = MustbeDate.(date)
      @spent = MustbeSpent.(spent)
      @task = MustbeTask.(task)
      @desc = desc
      @rate = MustbeRate.(rate)
    end
  end

  MustbeTrack = Sentry.new(:track, 'must be Track') {|val| val.is_a?(Track)}

  class Sheet
    attr_reader :project, :contributor, :hourly_rate

    def initialize(project:, contributor:, hourly_rate:)
      @project = MustbeMinStr.(project)
      @contributor = MustbeMinStr.(contributor)
      @hourly_rate = MustbeRate.(hourly_rate, :hourly_rate)
      @tracks = {}
    end

    def <<(track)
      tr = MustbeTrack.(track)
      total = spent(tr.date) + tr.spent
      MustbeSpent.(total, 'total spent', "on #{tr.date} exceed 24h")
      @tracks[tr.date] ||= []
      @tracks[tr.date] << track
      track
    end

   # @return [Array<Track>]
    def tracks
      fu = proc{|acc, (k, v)| acc.concat v}
      @tracks.inject([], &fu).dup
    end

    protected

    def spent(date)
      return 0 unless @tracks[date]
      @tracks[date].map(&:spent).sum
    end
  end
end
