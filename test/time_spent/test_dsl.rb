require_relative '../test_helper'

class TestDSL < Minitest::Test
  def build
    DSL.build do
      project 'TimeSpent'
      contributor 'nvoynov'
      hourly_rate 0.00
      date_format '%Y-%m-%d'

      track '2023-02-19', spent: 3 * 60, desc: <<~EOF
        designing core objects Track, Sheet, Project, DSL, and Filter
      EOF

      track '2023-02-20', spent: 1, task: '#doc', desc: <<~EOF
        designing README.md and CHANGELOG.md
      EOF

      track 2023_02_20, spent: '1h15m', desc: 'testing DSL'
    end
  end

  def test_build
    sheet = build
    assert_kind_of Sheet, sheet
    assert_equal 'TimeSpent', sheet.project
    assert_equal 'nvoynov', sheet.contributor
    assert_equal 0, sheet.hourly_rate
    assert_equal 3, sheet.tracks.size
  end

  def test_read
    sample = './test/time_spent/sample.timesheet'
    sheet = DSL.from(sample)
    assert_kind_of Sheet, sheet
    assert_equal 'TimeSpent', sheet.project
    assert_equal 'nvoynov', sheet.contributor
    assert_equal 0, sheet.hourly_rate
    assert_equal 3, sheet.tracks.size
  end
end
