require 'erb'
require_relative 'config'
require_relative 'service'

module TimeSpent

  # Render ERB for model and options
  class Sampler < Service

    def initialize(model, optns)
      @model = model
      @optns = optns
    end

    def call
      sample = @optns.delete(:report)
      sample = File.join(TimeSpent.samples, sample + '.md.erb')
      render(File.read(sample))
    end

    protected

    def render(sample)
      ERB.new(sample, trim_mode: "-").result(self.binding)
    end
  end
end
