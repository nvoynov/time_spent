require 'psych'

module TimeSpent
  DATE_PARSE_FORMAT = '%Y-%m-%d'.freeze 
  TIMESPENT = 'timespent'.freeze
  TIMESHEET = 'timesheet'.freeze
  TIMESPENT_EXT = ".#{TIMESHEET}".freeze
  TIMESPENT_FLD = ".#{TIMESPENT}".freeze
  TIMESPENT_PAT = "*.#{TIMESHEET}".freeze

  class << self
    def root
      dir = File.dirname(__dir__)
      File.expand_path("..", dir)
    end

    def samples
      File.join(root, 'lib', 'assets', 'samples')
    end

    def reports
      Dir.glob("#{samples}/*.md.erb").map{ File.basename(_1, '.md.erb')}
    end

    # @return [Array<String>] registered folders
    def registered
      @registered ||= File.exist?(ROSTER) ? Psych.load_file(ROSTER) : []
      @registered.dup
    end

    # register project folder
    # @param dir [String]
    def register(dir = Dir.pwd)
      return if registered.include?(dir)
      @registered << dir
      File.write(ROSTER, Psych.dump(@registered))
    end
  end

  ROSTER = File.join(Dir.home, ".#{TIMESPENT}.yml").freeze

end
