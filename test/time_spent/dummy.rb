require_relative '../test_helper'

module Dummy
  extend self

  def tracks(project, contributor)
    today = Date.today
    [{date: today.prev_day(8), spent: 1 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today.prev_day(7), spent: 2 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today.prev_day(6), spent: 3 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today.prev_day(5), spent: 4 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today.prev_day(4), spent: 5 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today.prev_day(3), spent: 6 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today.prev_day(2), spent: 7 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today.prev_day(1), spent: 8 * 60, rate: 10.0, task: '#test', desc: ''},
     {date: today, spent: 8 * 60, rate: 10.0, task: '#test', desc: ''},
    ].map{|payload| TrackDecor.new(Track.new(**payload), project, contributor)}
  end
end
