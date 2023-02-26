require 'optparse'
require_relative 'intlzr'
require_relative 'loader'
require_relative 'filter'
require_relative 'sampler'
require_relative 'version'

module TimeSpent

  module CLI
    extend self

    Error = Class.new(StandardError)

    def help
      puts BANNER
      puts
      puts PARSER
    end

    # $ timespent init
    def init
      log = Intlzr.()
      puts log.join(?\n)
    end

    # $ timespent summary this week
    def report(args)
      params = parse(args)
      filter = params.except(:report, :allround)
      wdir = Dir.getwd
      dirs = [wdir]
      dirs.concat TimeSpent.registered if params[:allround]
      tracks = Loader.(dirs).select(&Filter.(filter))
      puts Sampler.(tracks, params)
      TimeSpent.register wdir
    rescue Error => e
      puts e.message
    rescue => e
      puts "! Please report the error backtrace"
      puts "! https://github.com/nvoynov/time_spent/issues"
      puts e.full_message
    end

    protected

    PROPER_FORMAT = '%Y-%m-%d'
    PROPER_PERIOD = %w[today yesterday this prev week month year].freeze
    PROPER_REPORT = TimeSpent.reports.dup.freeze

    def check_report!(arg)
      return if PROPER_REPORT.include?(arg)
      reports = PROPER_REPORT.map{"\"#{_1}\""}.join(', ')
      raise Error, <<~EOF
        unknown report "#{arg}"
        specify one of #{reports}
      EOF
    end

    def check_date!(name, val)
      Date.strptime(val, PROPER_FORMAT)
    rescue => _
      raise Error, "\"#{name} #{val}\" should follow YYYY-MM-DD format"
    end

    def check_period!(period)
      faulty = period.split(?\s).select{ !PROPER_PERIOD.include?(_1) }
      return unless faulty.any?
      fjoin = faulty.map{"\"#{_1}\""}.join(', ')
      raise Error, "unknown period #{fjoin}"
    end

    # @param args [Array<String>] ARGV
    # @return [Hash]
    def parse(args)
      {}.tap{|opts|
        PARSER.parse(args, into: opts)
        arg0 = args.shift&.downcase
        opts[:report] = PROPER_REPORT.include?(arg0) ? arg0 : 'summary'
        args.unshift(arg0) if arg0 && !PROPER_REPORT.include?(arg0)
        period = [].tap{|w| w << args.shift while args.first =~ /^\w/}.join(?\s)
        opts[:period] = period unless period.empty?
        check_report!(opts[:report]) if opts[:report]
        check_period!(opts[:period]) if opts[:period]
        check_date!('--from', opts[:from]) if opts[:from]
        check_date!('--till', opts[:till]) if opts[:till]
      }
    end

    BANNER = <<~EOF
      = TimeSpent v#{VERSION} = TimeSheet DSL and Reporting
      see github.com/nvoynov/time_spent
    EOF

    PARSER = OptionParser.new{|cmd|
      cmd.banner = "Usage:\n\n  $ timespent [REPORT] [PERIOD] [OPTIONS]"
      cmd.on('REPORT',
        <<~EOF
          #{?\s.ljust(3)} summary (default) / minutes / daily / weekly / monthly
        EOF
      )
      cmd.on('PERIOD',
        <<~EOF
          #{?\s.ljust(3)} today / yesterday
          #{?\s.ljust(3)} this day / week / month / year
          #{?\s.ljust(3)} prev day / week / month / year
        EOF
      )
      cmd.on('OPTIONS')
      cmd.on('-f FROM', '--from FROM', 'period FROM', String)
      cmd.on('-t TILL', '--till TILL', 'period TILL', String)
      cmd.on('--task TASK', 'for TASK', String)
      cmd.on('-c CONTRIBUTOR', '--contributor CONTRIBUTOR', 'contributor', String)
      cmd.on('-p PROJECT', '--project PROJECT', 'project', String)
      cmd.on('--allround', 'from all known folders', TrueClass)
    }
  end

end
