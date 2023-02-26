require_relative '../test_helper'
require 'date'

class Sheet
  public :spent
end

class TestSheet < Minitest::Test
  def kwargs
    {project: 'TimeSpent', contributor: 'nvoynov', hourly_rate: 0}
  end

  def test_new
    sheet = Sheet.new(**kwargs)
    assert_equal 'TimeSpent', sheet.project
    assert_equal 'nvoynov', sheet.contributor
    assert_equal 0, sheet.hourly_rate
    assert_equal [], sheet.tracks
  end

  def test_add
    sheet = Sheet.new(**kwargs)
    assert_equal 0, sheet.tracks.size

    kwarg = {date: Date.today, spent: 1, task: '#test', desc: '', rate: 0}
    track = sheet << Track.new(**kwarg)
    assert_equal 1, sheet.tracks.size
    assert track
    assert_kind_of Track, track
    assert_equal 1, track.spent

    sheet << Track.new(**kwarg)
    assert_equal 2, sheet.tracks.size

    sheet << Track.new(**Hash[kwarg].tap{|hsh| hsh[:date] = Date.today.prev_day})
    assert_equal 3, sheet.tracks.size

    sheet = Sheet.new(**kwargs)
    sheet << Track.new(**kwarg)
    e = assert_raises(ArgumentError) {
      payload = Hash[kwarg].tap{|hsh| hsh[:spent] = 24 * 60}
      sheet << Track.new(**payload)
    }
    assert_match "total spent", e.message
    assert_match "exceed 24h", e.message
  end

  def test_spent
    sheet = Sheet.new(**kwargs)
    today = Date.today
    kwarg = {date: today, spent: 1, task: '#test', desc: '', rate: 0}
    sheet << Track.new(**kwarg)
    assert_equal 1, sheet.spent(today)
    sheet << Track.new(**kwarg)
    assert_equal 2, sheet.spent(today)
  end

end
