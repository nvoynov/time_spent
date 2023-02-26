require_relative '../test_helper'
require 'date'

class TestTrack < Minitest::Test
  def test_new
    kwarg = {date: Date.today, spent: 1, task: '#test', desc: '', rate: 0}
    track = Track.new(**kwarg)
    assert_equal Date.today, track.date
    assert_equal 1, track.spent
    assert_equal '#test', track.task
    assert_equal '', track.desc

    [ Hash[kwarg].tap{|hsh| hsh[:date] = 42},
      Hash[kwarg].tap{|hsh| hsh[:spent] = '42'},
      Hash[kwarg].tap{|hsh| hsh[:task] = '42'},
      Hash[kwarg].tap{|hsh| hsh[:rate] = '42'},
    ].each{|kwarg|
      assert_raises(ArgumentError) { Track.new(**kwarg) }
    }
  end
end
