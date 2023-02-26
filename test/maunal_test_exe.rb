require_relative 'test_helper'

describe 'exe/timespent' do
  it {
    system "ruby exe/timespent"
    system "ruby exe/timespent help"
    system "ruby exe/timespent init"
    system "ruby exe/timespent summary prev week"
  }
end
