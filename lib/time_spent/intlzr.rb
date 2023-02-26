require 'date'
require_relative 'config'
require_relative 'sampler'
require_relative 'service'

module TimeSpent

  # Initilizse Dir.pwd with .timesheet file
  class Intlzr < Service
    def call
      log = []
      if File.exist?(timespent)
        log << "Already initialized, skipped"
        log << ">>> #{timespent} <<<"
        log << File.read(timespent).lines.take(4).join
        return log
      end
      File.write(timespent, STARTER)
      log << "  created #{timespent}"
      log
    end

    def timespent
      @filename ||= File.basename(Dir.pwd) + '.' + TIMESHEET
    end

    STARTER = <<~EOF.freeze
      project '#{File.basename(Dir.pwd)}'
      contributor '#{ENV['USERNAME']}'
      hourly_rate 0.00
      date_format '%Y-%m-%d'

      # track '#{Date.today.prev_day}', task: '#doc', spent: 60, desc: 'TimeSpent'
      # track '#{Date.today}', task: '#dev', spent: 60, desc: 'TimeSpent'
    EOF
  end

end
