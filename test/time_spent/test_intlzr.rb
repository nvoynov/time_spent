require_relative '../test_helper'

describe Intlzr do
  it {
    Sandbox.() do
      log = Intlzr.()
      assert_match 'created', log.join
      assert File.exist?(File.basename(Dir.pwd + TIMESPENT_EXT))

      log = Intlzr.()
      assert_match 'skipped', log.join
    end
  }
end
