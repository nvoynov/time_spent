# frozen_string_literal: true

require "test_helper"

class TestTimeSpent < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TimeSpent::VERSION
  end
end
