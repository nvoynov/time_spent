# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "time_spent"
include TimeSpent
require "minitest/autorun"

# to preven from spoiling original roster
original = $VERBOSE
$VERBOSE = nil
TimeSpent::ROSTER = File.join(Dir.home, '.timespent.spec.yml').freeze
$VERBOSE = original

class Sandbox
  def self.call
    Dir.mktmpdir(['timespent']) {|dir|
      Dir.chdir(dir) { yield }
    }
  end
end
