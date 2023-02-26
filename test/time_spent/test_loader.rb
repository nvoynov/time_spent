require 'date'
require 'fileutils'
require_relative '../test_helper'

class TestDecor < Minitest::Test
  def test_decor
    kwarg = {date: Date.today, spent: 1, task: '#test', desc: '', rate: 0}
    track = Track.new(**kwarg)
    decor = Loader::TrackDecor.new(track, 'project', 'contributor')
    assert_equal 'project', decor.project
    assert_equal 'contributor', decor.contributor
    assert_equal 1, decor.spent
    assert_equal 0, decor.total
  end
end

class TestLoader < Minitest::Test
  def mksheet(project, contributor)
    <<~EOF
      project '#{project}'
      contributor '#{contributor}'
      hourly_rate 0.00
      date_format '%Y-%m-%d'

      track '2023-02-19', task: '#core', spent: 3 * 60, desc: 'Track and Sheet'
      track '2023-02-20', task: '#doc',  spent: 1 * 60, desc: 'README.md'
      track '2023-02-20', spent: '1h15m', desc: 'testing DSL'
    EOF
  end

  def test_call_local
    Sandbox.() do
      res = Loader.()
      assert_equal [], res

      # single sheet
      File.write('contr1.timesheet', mksheet('spec', 'contr1'))
      res = Loader.()
      refute res.empty?
      res.each{|tr| assert_kind_of TrackDecor, tr}

      # few sheets for few projects from few contributors
      File.write('contr2.timesheet', mksheet('spec', 'contr2'))
      File.write('proper.timesheet', mksheet('proper', 'contr1'))
      File.write('faulty.timesheet', mksheet('faulty', 'contr1') + "\n failed")

      FileUtils.mkdir(TIMESPENT_FLD)
      File.write(
        File.join(TIMESPENT_FLD, 'extra.timesheet'),
        mksheet('extra', 'contr1')
      )

      # faulty sheet
      out, _ = capture_io {
        tracks = Loader.()
        refute tracks.find{|tr| tr.project == 'faulty'}
        assert tracks.find{|tr| tr.project == 'proper'}
        assert tracks.find{|tr| tr.project == 'extra'}
        assert tracks.find{|tr| tr.contributor == 'contr1'}
        assert tracks.find{|tr| tr.contributor == 'contr2'}
      }
      assert_match "undefined local variable or method `failed'", out
    end
  end

  def test_call_registered
    Sandbox.() {
      %w[pro1 pro2].each do |pro|
        FileUtils.mkdir pro
        File.write("#{pro}/#{pro}#{TIMESPENT_EXT}", mksheet(pro, pro))
      end
      tracks = Loader.(%w[pro1 pro2])
      assert_kind_of Array, tracks
      assert_kind_of TrackDecor, tracks.first
      assert tracks.find{|tr| tr.project == 'pro1'}
      assert tracks.find{|tr| tr.project == 'pro2'}
    }
  end
end
