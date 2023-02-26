require_relative '../test_helper'
require 'fileutils'

module CLI
  public :parse
end

class TestCLI < Minitest::Test
  def test_help
    Sandbox.() {
      out, _ = capture_io { CLI.help }
      assert_match TimeSpent::VERSION, out
      assert_match 'Usage', out
    }
  end

  def test_init
    Sandbox.() {
      out, _ = capture_io { CLI.init }
      assert_match 'created', out
      assert_match TIMESHEET, out
      subj = File.basename(Dir.pwd) + '.' + TIMESHEET
      # puts subj, Dir.glob('*')
      assert File.exist?(subj)

      out, _ = capture_io { CLI.init }
      assert_match 'skipped', out
    }
  end

  def test_parse
    o = CLI.parse(%w[summary])
    assert_equal 'summary', o[:report]
    o = CLI.parse(%w[minutes])
    assert_equal 'minutes', o[:report]
    o = CLI.parse(%w[])
    assert_equal 'summary', o[:report]

    proper = %w[this prev].product(%w[week month year])
    proper << ['today']
    proper << ['yesterday']
    proper.each{|ar|
      s = ar.join ?\s
      o = CLI.parse(ar)
      assert_equal s, o[:period]
    }

    o = CLI.parse(%w[-c contrb])
    assert_equal 'contrb', o[:contributor]
    o = CLI.parse(%w[-p spec])
    assert_equal 'spec', o[:project]
    o = CLI.parse(%w[-f 2023-02-20])
    assert_equal '2023-02-20', o[:from]
    o = CLI.parse(%w[-t 2023-02-20])
    assert_equal '2023-02-20', o[:till]
    o = CLI.parse(%w[--task #doc])
    assert_equal '#doc', o[:task]
  end

  def test_report
    Sandbox.() {
      dummy = File.join(
        TimeSpent.root, 'test', 'time_spent', 'sample.timesheet'
      )
      FileUtils.cp dummy, Dir.pwd
      # puts Dir.glob('*')
      args = [
        %w[],
        %w[summary],
        %w[minutes],
        %w[summary this week],
        %w[summary this month],
        %w[summary this year],
        %w[summary --from 2023-01-01 --till 2023-02-28],
        %w[summary --project TimeSpent --contributor nvoynov --task #doc],
        %w[--allround],
      ]

      out, _ = capture_io{ args.each {|arg| CLI.report arg} }
      refute_match "undefined method", out
      out, _ = capture_io{ CLI.report %w[faulty arguments] }
      assert_match "unknown period", out
    }
  end
end
