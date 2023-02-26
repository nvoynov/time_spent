require 'date'
require_relative '../test_helper'

class TestFilter < Minitest::Test
  def subject
    Filter
  end

  Dummy = Struct.new(:date, :text)

  def test_eq
    fu = subject.eq(:text, 'val')
    assert fu.(Dummy.new(nil, 'val'))
    refute fu.(Dummy.new(nil, 'lav'))
  end

  def test_nq
    fu = subject.nq(:text, 'val')
    assert fu.(Dummy.new(nil, 'bla'))
    refute fu.(Dummy.new(nil, 'val'))
  end

  def test_in
    fu = subject.in(:text, %w[foo bar])
    assert fu.(Dummy.new(nil, 'foo'))
    assert fu.(Dummy.new(nil, 'bar'))
    refute fu.(Dummy.new(nil, 'buz'))
  end

  def test_match
    fu = subject.match(:text, /foo/)
    assert fu.(Dummy.new(nil, 'foo'))
    refute fu.(Dummy.new(nil, 'bar'))
  end

  def test_today
    fu = subject.today
    assert fu.(Dummy.new(Date.today, ''))
    refute fu.(Dummy.new(Date.today.prev_day, ''))
    refute fu.(Dummy.new(Date.today.next_day, ''))
  end

  def test_yesterday
    fu = subject.yesterday
    assert fu.(Dummy.new(Date.today.prev_day, ''))
    refute fu.(Dummy.new(Date.today, ''))
  end

  def test_this_week
    fu = subject.this_week
    assert fu.(Dummy.new(Date.today, ''))
    refute fu.(Dummy.new(Date.today.prev_day(7), ''))
  end

  def test_prev_week
    fu = subject.prev_week
    assert fu.(Dummy.new(Date.today.prev_day(7), ''))
    refute fu.(Dummy.new(Date.today, ''))
  end

  def test_this_month
    fu = subject.this_month
    assert fu.(Dummy.new(Date.today, ''))
    refute fu.(Dummy.new(Date.today.prev_month, ''))
  end

  def test_prev_month
    fu = subject.prev_month
    assert fu.(Dummy.new(Date.today.prev_month, ''))
    refute fu.(Dummy.new(Date.today, ''))
  end

  def test_this_year
    fu = subject.this_year
    assert fu.(Dummy.new(Date.today, ''))
    refute fu.(Dummy.new(Date.today.prev_year, ''))
  end

  def test_prev_year
    fu = subject.prev_year
    assert fu.(Dummy.new(Date.today.prev_year, ''))
    refute fu.(Dummy.new(Date.today, ''))
  end

  def test_build
    klass = Struct.new(:date, :project, :contributor)
    dummy = klass.new(Date.today, 'Dummy', 'test')
    colln = [dummy, dummy]

    optns = {period: 'today', project: 'Dummy', contributor: 'test'}
    assert_equal 2, colln.select(&subject.build(optns)).size
  end
end
