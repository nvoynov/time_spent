require_relative '../test_helper'

class TestConfig < Minitest::Test

  def test_reports
    # pp TimeSpent.reports 
  end

  def test_registered
    Sandbox.() {
      # puts File.expand_path(TimeSpent::ROSTER)
      # puts File.read(TimeSpent::ROSTER)
      TimeSpent::ROSTER.then{ File.delete(_1) if File.exist?(_1)}
      assert_equal [], TimeSpent.registered
      TimeSpent.register
      assert_equal [Dir.pwd], TimeSpent.registered
      TimeSpent.register(Dir.pwd)
      assert_equal [Dir.pwd], TimeSpent.registered

      TimeSpent.register('spec')
      assert_equal [Dir.pwd, 'spec'], TimeSpent.registered
    }
  end
end
