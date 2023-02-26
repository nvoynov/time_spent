require_relative 'test_helper'
require_relative 'time_spent/dummy'

describe 'Samples' do
  # let(:samples) { %w[monthly] }
  let(:samples) { %w[summary minutes daily weekly monthly] }

  it {
    samples.each{|sample|
      puts "\n>> #{sample}"

      puts ">> No tracks"
      puts Sampler.([], {report: sample, period: 'this day'})

      puts "\n>> One project"
      puts Sampler.(Dummy.tracks('Dummy', 'Contributor 1'), {report: sample})
    }
  }
end
