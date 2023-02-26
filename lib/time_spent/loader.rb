require 'delegate'
require_relative 'service'
require_relative 'config'
require_relative 'dsl'

module TimeSpent

  # Track decorator
  class TrackDecor < SimpleDelegator
    attr_reader :project
    attr_reader :contributor

    def initialize(obj, project, contributor)
      @project = project
      @contributor = contributor
      super(obj)
    end

    def total
      @total ||= (spent * rate / 60.0).round(2, :half => :even)
    end
  end

  # load sheets from acros dirs and return tracks!
  class Loader < Service
    def initialize(dirs = [Dir.pwd])
      @dirs = dirs
    end

    # @return [Array<TrackDecor>] read from current folder?
    def call
      tracks
    end

    protected

    # @return [Array<TrackDecor>]
    def tracks
      mkdeco = proc{|sh, tr| TrackDecor.new(tr, sh.project, sh.contributor)}
      sheets.inject([]){|ary, sh| ary.concat sh.tracks.map(&mkdeco.curry.(sh))}
    end

    # @return [Array<String>] with sheets inside @dirs
    def sheets
      # @todo dirs including <dir/.timespent/*.timesheet>
      ffun = proc{|dir|
        roots = Dir.glob(File.join(dir, TIMESPENT_PAT))
        extra = Dir.glob(File.join(dir, TIMESPENT_FLD, TIMESPENT_PAT))
        roots.concat extra
      }
      @dirs
        .map(&ffun).flatten
        .map{|sh| load(sh)}
        .compact # faulty sheets are nils
    end

    def load(name)
      DSL.from(name)
    rescue => e
      puts e.message
      puts e.backtrace.join(?\n)
      nil
    end
  end
end
